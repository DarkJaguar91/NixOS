//! EGL/GLES rendering: imports captured dmabufs as textures and draws them as
//! screens fixed in world space, arranged by the layout and seen through the
//! glasses' projection.

use std::ffi::c_void;
use std::os::fd::AsRawFd;

use anyhow::{anyhow, bail, Context as _, Result};
use glam::{Mat4, Quat, Vec3};
use glow::HasContext;
use khronos_egl as egl;

use xr_viewer::layout::{Layout, Shape};

use crate::capture::DmabufFrame;

type Egl = egl::Instance<egl::Static>;

// EGL_EXT_image_dma_buf_import(_modifiers)
const LINUX_DMA_BUF: egl::Enum = 0x3270;
const LINUX_DRM_FOURCC: egl::Attrib = 0x3271;
const PLANE_FD: [egl::Attrib; 4] = [0x3272, 0x3275, 0x3278, 0x3440];
const PLANE_OFFSET: [egl::Attrib; 4] = [0x3273, 0x3276, 0x3279, 0x3441];
const PLANE_PITCH: [egl::Attrib; 4] = [0x3274, 0x3277, 0x327A, 0x3442];
const PLANE_MODIFIER_LO: [egl::Attrib; 4] = [0x3443, 0x3445, 0x3447, 0x3449];
const PLANE_MODIFIER_HI: [egl::Attrib; 4] = [0x3444, 0x3446, 0x3448, 0x344A];
const DRM_FORMAT_MOD_INVALID: u64 = 0x00ff_ffff_ffff_ffff;

type ImageTargetTexture2d = unsafe extern "system" fn(target: u32, image: *const c_void);

const VERTEX_SHADER: &str = r#"#version 100
attribute vec3 position;
attribute vec2 uv;
uniform mat4 mvp;
uniform float flip_y;
varying vec2 v_uv;
void main() {
    v_uv = vec2(uv.x, mix(uv.y, 1.0 - uv.y, flip_y));
    gl_Position = mvp * vec4(position, 1.0);
}
"#;

const FRAGMENT_SHADER: &str = r#"#version 100
precision mediump float;
uniform sampler2D tex;
uniform float brightness;
varying vec2 v_uv;
void main() {
    gl_FragColor = vec4(texture2D(tex, v_uv).rgb * brightness, 1.0);
}
"#;

/// Screen brightness while head tracking is lost, so it's obvious the screens
/// have stopped staying put and are just following the head.
const UNTRACKED_BRIGHTNESS: f32 = 0.35;

/// Columns per curved screen; enough that the facets don't show.
const CURVE_SEGMENTS: usize = 48;

/// One captured output, shown as a panel.
struct Screen {
    texture: glow::Texture,
    image: Option<egl::Image>,
    y_invert: bool,
    /// Static triangle strip of (x, y, z, u, v) in world space (NWU).
    mesh: glow::Buffer,
    vertex_count: i32,
}

pub struct Renderer {
    egl: Egl,
    display: egl::Display,
    surface: egl::Surface,
    context: egl::Context,
    gl: glow::Context,
    image_target_texture: ImageTargetTexture2d,
    program: glow::Program,
    mvp_location: glow::UniformLocation,
    brightness_location: glow::UniformLocation,
    flip_y_location: glow::UniformLocation,
    /// The glasses' diagonal field of view, in degrees.
    display_fov: f32,
    /// In the layout's order.
    screens: Vec<Screen>,
}

impl Renderer {
    /// `wl_display` and `wl_egl_window` are the raw libwayland pointers.
    pub fn new(
        wl_display: *mut c_void,
        wl_egl_window: *mut c_void,
        layout: &Layout,
        display_fov: f32,
    ) -> Result<Self> {
        let egl = egl::Instance::new(egl::Static);
        let display =
            unsafe { egl.get_display(wl_display) }.ok_or_else(|| anyhow!("no EGL display"))?;
        egl.initialize(display).context("eglInitialize")?;
        egl.bind_api(egl::OPENGL_ES_API).context("eglBindAPI")?;

        let config = egl
            .choose_first_config(
                display,
                &[
                    egl::SURFACE_TYPE,
                    egl::WINDOW_BIT,
                    egl::RENDERABLE_TYPE,
                    egl::OPENGL_ES2_BIT,
                    egl::RED_SIZE,
                    8,
                    egl::GREEN_SIZE,
                    8,
                    egl::BLUE_SIZE,
                    8,
                    egl::NONE,
                ],
            )?
            .ok_or_else(|| anyhow!("no suitable EGL config"))?;
        let context = egl.create_context(
            display,
            config,
            None,
            &[egl::CONTEXT_CLIENT_VERSION, 2, egl::NONE],
        )?;
        let surface = unsafe { egl.create_window_surface(display, config, wl_egl_window, None) }?;
        egl.make_current(display, Some(surface), Some(surface), Some(context))?;
        // Present every vblank of the glasses; swap blocks until then.
        egl.swap_interval(display, 1)?;

        let gl = unsafe {
            glow::Context::from_loader_function(|name| {
                egl.get_proc_address(name)
                    .map_or(std::ptr::null(), |f| f as *const c_void)
            })
        };
        let image_target_texture: ImageTargetTexture2d = unsafe {
            std::mem::transmute(
                egl.get_proc_address("glEGLImageTargetTexture2DOES")
                    .ok_or_else(|| anyhow!("GL_OES_EGL_image is unsupported"))?,
            )
        };

        unsafe {
            let program = link_program(&gl)?;
            let mvp_location = gl
                .get_uniform_location(program, "mvp")
                .ok_or_else(|| anyhow!("mvp uniform missing"))?;
            let brightness_location = gl
                .get_uniform_location(program, "brightness")
                .ok_or_else(|| anyhow!("brightness uniform missing"))?;
            let flip_y_location = gl
                .get_uniform_location(program, "flip_y")
                .ok_or_else(|| anyhow!("flip_y uniform missing"))?;
            let screens = build_screens(&gl, layout, display_fov)?;

            Ok(Self {
                egl,
                display,
                surface,
                context,
                gl,
                image_target_texture,
                program,
                mvp_location,
                brightness_location,
                flip_y_location,
                display_fov,
                screens,
            })
        }
    }

    /// Switches to a new layout: every screen is rebuilt, and shows nothing
    /// until its next captured frame arrives.
    pub fn set_layout(&mut self, layout: &Layout) -> Result<()> {
        self.free_screens();
        self.screens = unsafe { build_screens(&self.gl, layout, self.display_fov)? };
        Ok(())
    }

    fn free_screens(&mut self) {
        for screen in self.screens.drain(..) {
            if let Some(image) = screen.image {
                let _ = self.egl.destroy_image(self.display, image);
            }
            unsafe {
                self.gl.delete_texture(screen.texture);
                self.gl.delete_buffer(screen.mesh);
            }
        }
    }

    /// Replaces screen `index`'s contents with a captured frame.
    pub fn import(&mut self, index: usize, frame: &DmabufFrame) -> Result<()> {
        let mut attribs = vec![
            egl::WIDTH as egl::Attrib,
            frame.width as egl::Attrib,
            egl::HEIGHT as egl::Attrib,
            frame.height as egl::Attrib,
            LINUX_DRM_FOURCC,
            frame.format as egl::Attrib,
        ];
        for (i, plane) in frame.planes.iter().enumerate() {
            let Some(plane) = plane else {
                bail!("missing plane {i}")
            };
            attribs.extend([
                PLANE_FD[i],
                plane.fd.as_raw_fd() as egl::Attrib,
                PLANE_OFFSET[i],
                plane.offset as egl::Attrib,
                PLANE_PITCH[i],
                plane.stride as egl::Attrib,
            ]);
            if frame.modifier != DRM_FORMAT_MOD_INVALID {
                attribs.extend([
                    PLANE_MODIFIER_LO[i],
                    (frame.modifier & 0xffff_ffff) as egl::Attrib,
                    PLANE_MODIFIER_HI[i],
                    (frame.modifier >> 32) as egl::Attrib,
                ]);
            }
        }
        attribs.push(egl::NONE as egl::Attrib);

        // EGL dups the fds, so the frame can be dropped once this returns.
        let image = unsafe {
            self.egl.create_image(
                self.display,
                egl::Context::from_ptr(egl::NO_CONTEXT),
                LINUX_DMA_BUF,
                egl::ClientBuffer::from_ptr(std::ptr::null_mut()),
                &attribs,
            )
        }
        .context("importing dmabuf")?;

        let screen = &mut self.screens[index];
        unsafe {
            self.gl.bind_texture(glow::TEXTURE_2D, Some(screen.texture));
            (self.image_target_texture)(glow::TEXTURE_2D, image.as_ptr());
        }
        if let Some(old) = screen.image.replace(image) {
            self.egl.destroy_image(self.display, old)?;
        }
        screen.y_invert = frame.y_invert;
        Ok(())
    }

    /// Draws one frame and presents it. With no `orientation` (tracking lost),
    /// the screens stay straight ahead of the head, dimmed.
    pub fn render(&mut self, size: (i32, i32), orientation: Option<Quat>) -> Result<()> {
        let gl = &self.gl;
        unsafe {
            gl.viewport(0, 0, size.0, size.1);
            // Black is transparent on the glasses
            gl.clear_color(0.0, 0.0, 0.0, 1.0);
            gl.clear(glow::COLOR_BUFFER_BIT);

            let mvp = projection(size, self.display_fov)
                * world_to_eye(orientation.unwrap_or(Quat::IDENTITY));
            gl.use_program(Some(self.program));
            let brightness = if orientation.is_some() {
                1.0
            } else {
                UNTRACKED_BRIGHTNESS
            };
            gl.uniform_1_f32(Some(&self.brightness_location), brightness);
            gl.uniform_matrix_4_f32_slice(Some(&self.mvp_location), false, &mvp.to_cols_array());

            for screen in self.screens.iter().filter(|s| s.image.is_some()) {
                let flip = if screen.y_invert { 1.0 } else { 0.0 };
                gl.uniform_1_f32(Some(&self.flip_y_location), flip);
                gl.bind_texture(glow::TEXTURE_2D, Some(screen.texture));
                gl.bind_buffer(glow::ARRAY_BUFFER, Some(screen.mesh));
                let stride = 5 * 4;
                gl.enable_vertex_attrib_array(0);
                gl.vertex_attrib_pointer_f32(0, 3, glow::FLOAT, false, stride, 0);
                gl.enable_vertex_attrib_array(1);
                gl.vertex_attrib_pointer_f32(1, 2, glow::FLOAT, false, stride, 3 * 4);
                gl.draw_arrays(glow::TRIANGLE_STRIP, 0, screen.vertex_count);
            }
        }
        self.egl
            .swap_buffers(self.display, self.surface)
            .context("eglSwapBuffers")?;
        Ok(())
    }
}

impl Drop for Renderer {
    fn drop(&mut self) {
        self.free_screens();
        let _ = self.egl.make_current(self.display, None, None, None);
        let _ = self.egl.destroy_surface(self.display, self.surface);
        let _ = self.egl.destroy_context(self.display, self.context);
    }
}

/// Perspective matching the glasses' optics, from a diagonal field of view.
fn projection(size: (i32, i32), diagonal_fov_deg: f32) -> Mat4 {
    let (w, h) = (size.0.max(1) as f32, size.1.max(1) as f32);
    let half_diag = (diagonal_fov_deg.to_radians() / 2.0).tan();
    let half_v = half_diag * h / w.hypot(h);
    let (f, aspect, near, far) = (1.0 / half_v, w / h, 0.01, 100.0);
    Mat4::from_cols(
        glam::Vec4::new(f / aspect, 0.0, 0.0, 0.0),
        glam::Vec4::new(0.0, f, 0.0, 0.0),
        glam::Vec4::new(0.0, 0.0, (far + near) / (near - far), -1.0),
        glam::Vec4::new(0.0, 0.0, 2.0 * far * near / (near - far), 0.0),
    )
}

/// World (NWU, as the driver reports it) into GL eye space: undo the head's
/// rotation, then map x forward/y left/z up onto -z forward/x right/y up.
fn world_to_eye(orientation: Quat) -> Mat4 {
    let nwu_to_gl = Mat4::from_cols(
        Vec3::new(0.0, 0.0, -1.0).extend(0.0),
        Vec3::new(-1.0, 0.0, 0.0).extend(0.0),
        Vec3::new(0.0, 1.0, 0.0).extend(0.0),
        glam::Vec4::W,
    );
    nwu_to_gl * Mat4::from_quat(orientation.inverse())
}

/// GPU resources for each screen in `layout`: its mesh, and a texture for
/// captured frames.
unsafe fn build_screens(
    gl: &glow::Context,
    layout: &Layout,
    display_fov: f32,
) -> Result<Vec<Screen>> {
    let mut screens = Vec::with_capacity(layout.screens.len());
    for vertices in screen_meshes(layout, display_fov) {
        let mesh = gl.create_buffer().map_err(|e| anyhow!(e))?;
        gl.bind_buffer(glow::ARRAY_BUFFER, Some(mesh));
        gl.buffer_data_u8_slice(
            glow::ARRAY_BUFFER,
            bytemuck_f32(&vertices),
            glow::STATIC_DRAW,
        );
        let texture = gl.create_texture().map_err(|e| anyhow!(e))?;
        gl.bind_texture(glow::TEXTURE_2D, Some(texture));
        for (param, value) in [
            (glow::TEXTURE_MIN_FILTER, glow::LINEAR),
            (glow::TEXTURE_MAG_FILTER, glow::LINEAR),
            (glow::TEXTURE_WRAP_S, glow::CLAMP_TO_EDGE),
            (glow::TEXTURE_WRAP_T, glow::CLAMP_TO_EDGE),
        ] {
            gl.tex_parameter_i32(glow::TEXTURE_2D, param, value as i32);
        }
        screens.push(Screen {
            texture,
            image: None,
            y_invert: false,
            mesh,
            vertex_count: (vertices.len() / 5) as i32,
        });
    }
    Ok(screens)
}

/// Each screen's triangle strip in world space (NWU: x forward, y left, z
/// up): columns of (top, bottom) vertex pairs from left to right, as
/// (x, y, z, u, v) with v = 0 at the top of the image.
///
/// A screen's size comes from the glasses' view: at `size` 1 its diagonal
/// spans the whole field of view, one unit away. Flat screens are planes
/// turned to face the viewer, stepped by their angular size plus the gap.
/// Curved screens are pieces of one unit cylinder around the viewer, so
/// columns wrap around and rows stack straight up.
fn screen_meshes(layout: &Layout, display_fov: f32) -> Vec<Vec<f32>> {
    let (w, h) = (layout.resolution[0] as f32, layout.resolution[1] as f32);
    let half_diag = (display_fov.to_radians() / 2.0).tan() * layout.size;
    let half_w = half_diag * w / w.hypot(h);
    let half_h = half_diag * h / w.hypot(h);
    let gap = layout.gap.to_radians();

    layout
        .screens
        .iter()
        .map(|screen| {
            let [col, row] = screen.cell.map(|c| c as f32);
            let mut vertices = Vec::new();
            match layout.shape {
                Shape::Flat => {
                    // Columns to the right turn toward -y; rows tip upward
                    let yaw = -col * (2.0 * half_w.atan() + gap);
                    let pitch = row * (2.0 * half_h.atan() + gap);
                    let rotation = Quat::from_rotation_z(yaw) * Quat::from_rotation_y(-pitch);
                    for u in [0.0, 1.0] {
                        let y = half_w * (1.0 - 2.0 * u);
                        for (z, v) in [(half_h, 0.0), (-half_h, 1.0)] {
                            let p = rotation * Vec3::new(1.0, y, z);
                            vertices.extend([p.x, p.y, p.z, u, v]);
                        }
                    }
                }
                Shape::Curved => {
                    // Arc length matches the flat width, keeping pixel density
                    let arc = 2.0 * half_w;
                    let center_yaw = -col * (arc + gap);
                    let center_z = row * (2.0 * half_h + gap);
                    for i in 0..=CURVE_SEGMENTS {
                        let u = i as f32 / CURVE_SEGMENTS as f32;
                        let yaw = center_yaw + (0.5 - u) * arc;
                        for (z, v) in [(center_z + half_h, 0.0), (center_z - half_h, 1.0)] {
                            vertices.extend([yaw.cos(), yaw.sin(), z, u, v]);
                        }
                    }
                }
            }
            vertices
        })
        .collect()
}

fn bytemuck_f32(data: &[f32]) -> &[u8] {
    unsafe { std::slice::from_raw_parts(data.as_ptr().cast(), std::mem::size_of_val(data)) }
}

unsafe fn link_program(gl: &glow::Context) -> Result<glow::Program> {
    let program = gl.create_program().map_err(|e| anyhow!(e))?;
    let mut shaders = Vec::new();
    for (kind, source) in [
        (glow::VERTEX_SHADER, VERTEX_SHADER),
        (glow::FRAGMENT_SHADER, FRAGMENT_SHADER),
    ] {
        let shader = gl.create_shader(kind).map_err(|e| anyhow!(e))?;
        gl.shader_source(shader, source);
        gl.compile_shader(shader);
        if !gl.get_shader_compile_status(shader) {
            bail!("shader compile failed: {}", gl.get_shader_info_log(shader));
        }
        gl.attach_shader(program, shader);
        shaders.push(shader);
    }
    gl.bind_attrib_location(program, 0, "position");
    gl.bind_attrib_location(program, 1, "uv");
    gl.link_program(program);
    if !gl.get_program_link_status(program) {
        bail!("program link failed: {}", gl.get_program_info_log(program));
    }
    for shader in shaders {
        gl.detach_shader(program, shader);
        gl.delete_shader(shader);
    }
    Ok(program)
}
