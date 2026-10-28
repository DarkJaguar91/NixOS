//! xr-viewer: shows Umbriel virtual outputs on XR glasses as screens that stay
//! put while the head moves, arranged by the layout file. It creates an output
//! per screen, captures each with wlr-export-dmabuf, reads head pose from
//! XRLinuxDriver, draws fullscreen on the glasses' own output, and keeps the
//! compositor's output layout matching the screens. Saving the layout file
//! applies it live: only added or removed screens' outputs come or go.

mod capture;
mod gfx;
mod outputs;
mod pose;
mod screens;

use std::collections::HashMap;
use std::path::PathBuf;

use std::os::fd::AsRawFd;

use anyhow::{anyhow, bail, Context as _, Result};
use wayland_client::protocol::{
    wl_compositor, wl_output, wl_pointer, wl_region, wl_registry, wl_seat, wl_surface,
};
use wayland_client::{delegate_noop, Connection, Dispatch, Proxy, QueueHandle, WEnum};
use wayland_protocols::xdg::shell::client::{xdg_surface, xdg_toplevel, xdg_wm_base};
use wayland_protocols::xdg::xdg_output::zv1::client::{
    zxdg_output_manager_v1::ZxdgOutputManagerV1,
    zxdg_output_v1::{self, ZxdgOutputV1},
};
use wayland_protocols_wlr::export_dmabuf::v1::client::{
    zwlr_export_dmabuf_frame_v1::{self, ZwlrExportDmabufFrameV1},
    zwlr_export_dmabuf_manager_v1::ZwlrExportDmabufManagerV1,
};

use capture::{DmabufFrame, Plane};
use gfx::Renderer;
use outputs::OutputLayout;
use pose::PoseReader;
use screens::LayoutWatcher;
use xr_viewer::layout::Layout;

const USAGE: &str = "\
usage: xr-viewer [--layout FILE] [--target NAME] [--size FACTOR] [--fov DEGREES]
       xr-viewer [--layout FILE] --list
       xr-viewer [--target NAME] --reset-glasses

  --layout FILE    screen layout (default: ~/.config/xr-session/layout.toml;
                   edit with xr-layout)
  --list           print each screen's output name and mode, and exit
  --reset-glasses  move the glasses' output back beside the monitors, and
                   exit (xr-session does this once the screens are gone)
  --target NAME    output of the glasses (default: first output whose make or
                   description mentions VITURE, XREAL, Rokid or RayNeo)
  --size FACTOR    override the layout's screen size
  --fov DEGREES    glasses' diagonal field of view (default: 43, VITURE Pro)
";

const GLASSES_MAKES: [&str; 4] = ["VITURE", "XREAL", "ROKID", "RAYNEO"];

struct Args {
    layout: PathBuf,
    list: bool,
    reset_glasses: bool,
    target: Option<String>,
    size: Option<f32>,
    display_fov: f32,
}

fn parse_args() -> Result<Args> {
    let mut args = Args {
        layout: Layout::default_path(),
        list: false,
        reset_glasses: false,
        target: None,
        size: None,
        display_fov: 43.0,
    };
    let mut it = std::env::args().skip(1);
    while let Some(arg) = it.next() {
        let mut value = || it.next().ok_or_else(|| anyhow!("{arg} needs a value"));
        match arg.as_str() {
            "--layout" => args.layout = value()?.into(),
            "--list" => args.list = true,
            "--reset-glasses" => args.reset_glasses = true,
            "--target" => args.target = Some(value()?),
            "--size" => args.size = Some(value()?.parse().context("--size")?),
            "--fov" => args.display_fov = value()?.parse().context("--fov")?,
            "-h" | "--help" => {
                print!("{USAGE}");
                std::process::exit(0);
            }
            _ => bail!("unknown argument {arg}\n\n{USAGE}"),
        }
    }
    Ok(args)
}

#[derive(Default)]
struct Output {
    /// None once the output is gone.
    output: Option<wl_output::WlOutput>,
    /// Registry name of its wl_output global.
    global: u32,
    name: String,
    make: String,
    description: String,
    /// Exact width in the compositor's layout, from xdg-output.
    logical_width: Option<i32>,
    has_xdg_output: bool,
}

/// Whether an output's make/model/description text names XR glasses.
fn names_glasses(text: &str) -> bool {
    let text = text.to_uppercase();
    GLASSES_MAKES.iter().any(|make| text.contains(make))
}

#[derive(Default)]
struct State {
    compositor: Option<wl_compositor::WlCompositor>,
    wm_base: Option<xdg_wm_base::XdgWmBase>,
    export_dmabuf: Option<ZwlrExportDmabufManagerV1>,
    xdg_output_manager: Option<ZxdgOutputManagerV1>,
    outputs: Vec<Output>,
    output_layout: OutputLayout,

    /// Size of the fullscreen surface, once the compositor has configured it.
    size: Option<(i32, i32)>,
    pending_size: (i32, i32),
    closed: bool,

    /// Per screen, in layout order: the frame being received, the latest
    /// complete one awaiting import, and whether a capture is outstanding (a
    /// new one starts once it finishes).
    captures: Vec<Capture>,
    /// Bumped when the layout changes; frames still in flight from before
    /// carry the old value and are dropped.
    capture_generation: u64,
}

#[derive(Default)]
struct Capture {
    receiving: DmabufFrame,
    ready: Option<DmabufFrame>,
    pending: bool,
}

fn main() -> Result<()> {
    let args = parse_args()?;
    let mut layout = Layout::load(&args.layout)?;
    if let Some(size) = args.size {
        layout.size = size;
    }
    if args.list {
        for screen in &layout.screens {
            println!("{} {}", screen.name, layout.mode());
        }
        return Ok(());
    }
    let mut watcher = LayoutWatcher::new(args.layout.clone());
    let is_glasses = |name: &str, text: &str| match &args.target {
        Some(target) => name == target,
        None => names_glasses(text),
    };

    let conn = Connection::connect_to_env().context("connecting to the Wayland compositor")?;
    let mut queue = conn.new_event_queue();
    let qh = queue.handle();
    conn.display().get_registry(&qh, ());

    let mut state = State::default();
    // Bind globals, then collect the outputs' names, descriptions and sizes
    queue.roundtrip(&mut state)?;
    state.request_xdg_outputs(&qh);
    queue.roundtrip(&mut state)?;

    if args.reset_glasses {
        // With no screens, the glasses go right of the monitors
        let empty = Layout {
            screens: Vec::new(),
            ..layout
        };
        let deadline = std::time::Instant::now() + std::time::Duration::from_secs(3);
        loop {
            let widths = state.logical_widths();
            state.output_layout.sync(&empty, is_glasses, &widths, &qh);
            if state.output_layout.settled() {
                return Ok(());
            }
            if std::time::Instant::now() > deadline {
                bail!("timed out moving the glasses' output");
            }
            queue.roundtrip(&mut state)?;
        }
    }

    let compositor = state
        .compositor
        .clone()
        .ok_or_else(|| anyhow!("no wl_compositor"))?;
    let wm_base = state
        .wm_base
        .clone()
        .ok_or_else(|| anyhow!("no xdg_wm_base"))?;
    let export_dmabuf = state
        .export_dmabuf
        .clone()
        .ok_or_else(|| anyhow!("compositor lacks wlr-export-dmabuf"))?;

    let target = find_output(&state.outputs, |o| {
        is_glasses(&o.name, &format!("{} {}", o.make, o.description))
    })
    .ok_or_else(|| anyhow!("glasses output not found; pass --target"))?;
    if layout
        .screens
        .iter()
        .any(|s| find_output(&state.outputs, |o| o.name == s.name) == Some(target.clone()))
    {
        bail!("the glasses' output can't also be a screen");
    }

    // Create the screens' outputs, unless left over from a session that
    // didn't clean up, and wait for them to show up
    for screen in &layout.screens {
        if find_output(&state.outputs, |o| o.name == screen.name).is_none() {
            screens::create(&screen.name, &layout.mode());
        }
    }
    screens::record(&layout);
    let deadline = std::time::Instant::now() + std::time::Duration::from_secs(3);
    while layout
        .screens
        .iter()
        .any(|s| find_output(&state.outputs, |o| o.name == s.name).is_none())
    {
        if std::time::Instant::now() > deadline {
            bail!("the screens' outputs didn't appear");
        }
        queue.roundtrip(&mut state)?;
    }
    state.captures = layout.screens.iter().map(|_| Capture::default()).collect();

    let surface = compositor.create_surface(&qh, ());
    let xdg_surface = wm_base.get_xdg_surface(&surface, &qh, ());
    let toplevel = xdg_surface.get_toplevel(&qh, ());
    toplevel.set_title("XR viewer".into());
    toplevel.set_app_id("xr-viewer".into());
    toplevel.set_fullscreen(Some(&target));
    surface.commit();

    while state.size.is_none() {
        queue.blocking_dispatch(&mut state)?;
        if state.closed {
            return Ok(());
        }
    }

    let (w, h) = state.size.unwrap();
    let egl_window = wayland_egl::WlEglSurface::new(surface.id(), w, h)?;
    let mut renderer = Renderer::new(
        conn.backend().display_ptr().cast(),
        egl_window.ptr() as *mut _,
        &layout,
        args.display_fov,
    )?;
    // The EGL buffer may carry an alpha channel; declaring the whole surface
    // opaque lets the compositor skip whatever is beneath (the wallpaper) and
    // scan the viewer out directly rather than compositing the glasses.
    let set_opaque = |(w, h): (i32, i32)| {
        let region = compositor.create_region(&qh, ());
        region.add(0, 0, w, h);
        surface.set_opaque_region(Some(&region));
        region.destroy();
    };
    set_opaque((w, h));
    let mut size = (w, h);
    let mut pose = PoseReader::new();
    let mut tracking = false;

    while !state.closed {
        dispatch_without_blocking(&conn, &mut queue, &mut state)?;
        state.request_xdg_outputs(&qh);
        let widths = state.logical_widths();
        state.output_layout.sync(&layout, is_glasses, &widths, &qh);

        if let Some(mut new_layout) = watcher.poll() {
            if let Some(size) = args.size {
                new_layout.size = size;
            }
            if new_layout != layout {
                apply_layout(&layout, &new_layout, &mut state, &mut renderer)?;
                layout = new_layout;
            }
        }

        let generation = state.capture_generation;
        for (index, (capture, screen)) in state.captures.iter_mut().zip(&layout.screens).enumerate()
        {
            // Absent briefly after a reload adds the screen
            let Some(source) = find_output(&state.outputs, |o| o.name == screen.name) else {
                continue;
            };
            if !capture.pending {
                export_dmabuf.capture_output(1, &source, &qh, (index, generation));
                capture.pending = true;
            }
            if let Some(frame) = capture.ready.take() {
                if let Err(err) = renderer.import(index, &frame) {
                    eprintln!("xr-viewer: {err:#}");
                }
            }
        }
        if let Some(new_size) = state.size.filter(|s| *s != size) {
            egl_window.resize(new_size.0, new_size.1, 0, 0);
            set_opaque(new_size);
            size = new_size;
        }

        let orientation = pose.orientation();
        if orientation.is_some() != tracking {
            tracking = orientation.is_some();
            eprintln!(
                "xr-viewer: head tracking {}",
                if tracking { "active" } else { "lost" }
            );
        }
        renderer.render(size, orientation)?;
    }
    Ok(())
}

/// Moves from one layout to the next: outputs for removed screens are
/// destroyed (their windows move to another output) and added ones created;
/// screens kept by name keep their outputs and windows. Changed resolutions
/// and positions are applied by the output layout sync.
fn apply_layout(
    old: &Layout,
    new: &Layout,
    state: &mut State,
    renderer: &mut Renderer,
) -> Result<()> {
    let kept = |layout: &Layout, name: &str| layout.screens.iter().any(|s| s.name == name);
    for screen in old.screens.iter().filter(|s| !kept(new, &s.name)) {
        screens::destroy(&screen.name);
    }
    for screen in new.screens.iter().filter(|s| !kept(old, &s.name)) {
        screens::create(&screen.name, &new.mode());
    }
    screens::record(new);
    renderer.set_layout(new)?;
    state.captures = new.screens.iter().map(|_| Capture::default()).collect();
    state.capture_generation += 1;
    state.output_layout.mark_dirty();
    let names: Vec<_> = new.screens.iter().map(|s| s.name.as_str()).collect();
    eprintln!("xr-viewer: layout reloaded: {}", names.join(" "));
    Ok(())
}

impl State {
    /// Exact layout widths by output name, as far as xdg-output has told.
    fn logical_widths(&self) -> HashMap<String, i32> {
        self.outputs
            .iter()
            .filter_map(|o| Some((o.name.clone(), o.logical_width?)))
            .collect()
    }

    /// Asks for xdg-output details of outputs that don't have them yet,
    /// including ones plugged in after startup.
    fn request_xdg_outputs(&mut self, qh: &QueueHandle<Self>) {
        let Some(manager) = &self.xdg_output_manager else {
            return;
        };
        for (index, output) in self.outputs.iter_mut().enumerate() {
            if let (Some(wl_output), false) = (&output.output, output.has_xdg_output) {
                manager.get_xdg_output(wl_output, qh, index);
                output.has_xdg_output = true;
            }
        }
    }
}

fn find_output(outputs: &[Output], pred: impl Fn(&Output) -> bool) -> Option<wl_output::WlOutput> {
    outputs
        .iter()
        .find(|o| pred(o))
        .and_then(|o| o.output.clone())
}

/// Reads and dispatches whatever events have arrived, without waiting; the
/// render loop is paced by eglSwapBuffers instead.
fn dispatch_without_blocking(
    conn: &Connection,
    queue: &mut wayland_client::EventQueue<State>,
    state: &mut State,
) -> Result<()> {
    queue.dispatch_pending(state)?;
    conn.flush()?;
    if let Some(guard) = queue.prepare_read() {
        let mut fd = libc::pollfd {
            fd: guard.connection_fd().as_raw_fd(),
            events: libc::POLLIN,
            revents: 0,
        };
        if unsafe { libc::poll(&mut fd, 1, 0) } > 0 {
            guard.read()?;
        }
    }
    queue.dispatch_pending(state)?;
    Ok(())
}

impl Dispatch<wl_registry::WlRegistry, ()> for State {
    fn event(
        state: &mut Self,
        registry: &wl_registry::WlRegistry,
        event: wl_registry::Event,
        _: &(),
        _: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        let (name, interface, version) = match event {
            wl_registry::Event::Global {
                name,
                interface,
                version,
            } => (name, interface, version),
            wl_registry::Event::GlobalRemove { name } => {
                if let Some(output) = state.outputs.iter_mut().find(|o| o.global == name) {
                    if let Some(wl_output) = output.output.take() {
                        wl_output.release();
                    }
                    output.name.clear();
                }
                return;
            }
            _ => return,
        };
        match interface.as_str() {
            "wl_compositor" => {
                state.compositor = Some(registry.bind(name, version.min(4), qh, ()));
            }
            "xdg_wm_base" => state.wm_base = Some(registry.bind(name, version.min(2), qh, ())),
            "zwlr_export_dmabuf_manager_v1" => {
                state.export_dmabuf = Some(registry.bind(name, 1, qh, ()));
            }
            "zwlr_output_manager_v1" => state.output_layout.bind(registry, name, version, qh),
            "zxdg_output_manager_v1" => {
                state.xdg_output_manager = Some(registry.bind(name, version.min(3), qh, ()));
            }
            "wl_seat" => {
                registry.bind::<wl_seat::WlSeat, _, _>(name, version.min(5), qh, ());
            }
            "wl_output" if version >= 4 => {
                let index = state.outputs.len();
                let output = registry.bind(name, 4, qh, index);
                state.outputs.push(Output {
                    output: Some(output),
                    global: name,
                    ..Default::default()
                });
            }
            _ => {}
        }
    }
}

impl Dispatch<wl_output::WlOutput, usize> for State {
    fn event(
        state: &mut Self,
        _: &wl_output::WlOutput,
        event: wl_output::Event,
        index: &usize,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        let output = &mut state.outputs[*index];
        match event {
            wl_output::Event::Name { name } => output.name = name,
            wl_output::Event::Description { description } => output.description = description,
            wl_output::Event::Geometry { make, .. } => output.make = make,
            _ => {}
        }
    }
}

impl Dispatch<ZxdgOutputV1, usize> for State {
    fn event(
        state: &mut Self,
        _: &ZxdgOutputV1,
        event: zxdg_output_v1::Event,
        index: &usize,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        if let zxdg_output_v1::Event::LogicalSize { width, .. } = event {
            state.outputs[*index].logical_width = Some(width);
            state.output_layout.mark_dirty();
        }
    }
}

impl Dispatch<wl_seat::WlSeat, ()> for State {
    fn event(
        _: &mut Self,
        seat: &wl_seat::WlSeat,
        event: wl_seat::Event,
        _: &(),
        _: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        if let wl_seat::Event::Capabilities {
            capabilities: WEnum::Value(caps),
        } = event
        {
            if caps.contains(wl_seat::Capability::Pointer) {
                seat.get_pointer(qh, ());
            }
        }
    }
}

impl Dispatch<wl_pointer::WlPointer, ()> for State {
    fn event(
        _: &mut Self,
        pointer: &wl_pointer::WlPointer,
        event: wl_pointer::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        // The glasses' output should be out of the pointer's reach, but if it
        // gets here anyway, don't draw it head-locked over the screen.
        if let wl_pointer::Event::Enter { serial, .. } = event {
            pointer.set_cursor(serial, None, 0, 0);
        }
    }
}

impl Dispatch<xdg_wm_base::XdgWmBase, ()> for State {
    fn event(
        _: &mut Self,
        wm_base: &xdg_wm_base::XdgWmBase,
        event: xdg_wm_base::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        if let xdg_wm_base::Event::Ping { serial } = event {
            wm_base.pong(serial);
        }
    }
}

impl Dispatch<xdg_surface::XdgSurface, ()> for State {
    fn event(
        state: &mut Self,
        xdg_surface: &xdg_surface::XdgSurface,
        event: xdg_surface::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        if let xdg_surface::Event::Configure { serial } = event {
            xdg_surface.ack_configure(serial);
            let (w, h) = state.pending_size;
            // 0x0 leaves the size to us; the glasses are 1080p
            state.size = Some(if w > 0 && h > 0 { (w, h) } else { (1920, 1080) });
        }
    }
}

impl Dispatch<xdg_toplevel::XdgToplevel, ()> for State {
    fn event(
        state: &mut Self,
        _: &xdg_toplevel::XdgToplevel,
        event: xdg_toplevel::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        match event {
            xdg_toplevel::Event::Configure { width, height, .. } => {
                state.pending_size = (width, height);
            }
            xdg_toplevel::Event::Close => state.closed = true,
            _ => {}
        }
    }
}

impl Dispatch<ZwlrExportDmabufFrameV1, (usize, u64)> for State {
    fn event(
        state: &mut Self,
        frame: &ZwlrExportDmabufFrameV1,
        event: zwlr_export_dmabuf_frame_v1::Event,
        &(index, generation): &(usize, u64),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        use zwlr_export_dmabuf_frame_v1::Event;
        if generation != state.capture_generation {
            // Requested before a layout change; just let it go
            if matches!(event, Event::Ready { .. } | Event::Cancel { .. }) {
                frame.destroy();
            }
            return;
        }
        let capture = &mut state.captures[index];
        match event {
            Event::Frame {
                width,
                height,
                buffer_flags,
                format,
                mod_high,
                mod_low,
                num_objects,
                ..
            } => {
                // zwp_linux_buffer_params_v1 flags; 1 is y_invert
                let y_invert = buffer_flags & 1 != 0;
                capture.receiving = DmabufFrame {
                    width,
                    height,
                    format,
                    modifier: (u64::from(mod_high) << 32) | u64::from(mod_low),
                    y_invert,
                    planes: (0..num_objects).map(|_| None).collect(),
                };
            }
            Event::Object {
                index,
                fd,
                offset,
                stride,
                ..
            } => {
                if let Some(slot) = capture.receiving.planes.get_mut(index as usize) {
                    *slot = Some(Plane { fd, offset, stride });
                }
            }
            Event::Ready { .. } => {
                let received = std::mem::take(&mut capture.receiving);
                if received.complete() {
                    capture.ready = Some(received);
                }
                frame.destroy();
                capture.pending = false;
            }
            Event::Cancel { .. } => {
                capture.receiving = DmabufFrame::default();
                frame.destroy();
                capture.pending = false;
            }
            _ => {}
        }
    }
}

delegate_noop!(State: ignore wl_compositor::WlCompositor);
delegate_noop!(State: ignore wl_surface::WlSurface);
delegate_noop!(State: ignore wl_region::WlRegion);
delegate_noop!(State: ignore ZwlrExportDmabufManagerV1);
delegate_noop!(State: ignore ZxdgOutputManagerV1);
