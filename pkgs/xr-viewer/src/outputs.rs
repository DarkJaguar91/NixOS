//! Keeps the compositor's output layout matching the screen layout, through
//! wlr-output-management: the virtual screens on the grid right of the real
//! monitors at the layout's resolution, and the glasses' own output just past
//! them. Re-applied whenever the outputs change, e.g. when the glasses are
//! replugged and placed anew, or the layout is reloaded.

use std::collections::HashMap;
use std::time::{Duration, Instant};

use wayland_client::{event_created_child, Connection, Dispatch, Proxy, QueueHandle, WEnum};
use wayland_protocols_wlr::output_management::v1::client::{
    zwlr_output_configuration_head_v1::ZwlrOutputConfigurationHeadV1,
    zwlr_output_configuration_v1::{self, ZwlrOutputConfigurationV1},
    zwlr_output_head_v1::{self, ZwlrOutputHeadV1},
    zwlr_output_manager_v1::{self, ZwlrOutputManagerV1},
    zwlr_output_mode_v1::{self, ZwlrOutputModeV1},
};
use xr_viewer::layout::Layout;

use crate::State;

/// How long to wait before retrying a configuration the compositor refused.
const RETRY_AFTER_FAILURE: Duration = Duration::from_secs(5);

/// Heads and modes are keyed by protocol object id; ObjectId itself has
/// interior mutability, which makes it a poor hash key.
type Id = u32;

#[derive(Clone, Copy, Default)]
struct Mode {
    size: (i32, i32),
    /// In mHz.
    refresh: i32,
}

/// What a head should become: a position, and for screens a mode.
struct Wanted {
    position: (i32, i32),
    mode: Option<Mode>,
}

#[derive(Default)]
struct Head {
    proxy: Option<ZwlrOutputHeadV1>,
    name: String,
    description: String,
    make: String,
    model: String,
    enabled: bool,
    position: (i32, i32),
    mode: Option<Id>,
    scale: f64,
    transform: i32,
}

impl Head {
    /// Size in the compositor's logical coordinates, as near as the protocol
    /// can tell: its scale is 24.8 fixed point, so e.g. 1.2 arrives as
    /// 1.199219 and widths can come out a pixel or two off. Prefer xdg-output.
    fn logical_size(&self, modes: &HashMap<Id, Mode>) -> (i32, i32) {
        let (w, h) = self
            .mode
            .as_ref()
            .and_then(|m| modes.get(m))
            .map_or((0, 0), |m| m.size);
        // Odd transforms rotate by 90 or 270 degrees
        let (w, h) = if self.transform % 2 == 1 {
            (h, w)
        } else {
            (w, h)
        };
        let scale = if self.scale > 0.0 { self.scale } else { 1.0 };
        (
            (w as f64 / scale).round() as i32,
            (h as f64 / scale).round() as i32,
        )
    }
}

#[derive(Default)]
pub struct OutputLayout {
    manager: Option<ZwlrOutputManagerV1>,
    heads: HashMap<Id, Head>,
    modes: HashMap<Id, Mode>,
    serial: Option<u32>,
    /// Outputs changed since the layout was last checked.
    dirty: bool,
    applying: bool,
    failed_at: Option<Instant>,
}

impl OutputLayout {
    pub fn bind(
        &mut self,
        registry: &wayland_client::protocol::wl_registry::WlRegistry,
        name: u32,
        version: u32,
        qh: &QueueHandle<State>,
    ) {
        self.manager = Some(registry.bind(name, version.min(4), qh, ()));
    }

    /// Whether a sync has nothing left to do: positions checked and no
    /// configuration awaiting the compositor's answer.
    pub fn settled(&self) -> bool {
        self.serial.is_some() && !self.dirty && !self.applying
    }

    /// Has the next `sync` re-check positions, e.g. after an output resized.
    pub fn mark_dirty(&mut self) {
        self.dirty = true;
    }

    /// Moves outputs where `layout` wants them, and sets screens' modes to its
    /// resolution and refresh, if they aren't so already. Screens are matched
    /// by output name; the glasses by `is_glasses`, given
    /// an output's name and its make, model and description. `logical_widths`
    /// holds exact widths by output name, from xdg-output.
    pub fn sync(
        &mut self,
        layout: &Layout,
        is_glasses: impl Fn(&str, &str) -> bool,
        logical_widths: &HashMap<String, i32>,
        qh: &QueueHandle<State>,
    ) {
        let (Some(manager), Some(serial)) = (&self.manager, self.serial) else {
            return;
        };
        if !self.dirty || self.applying {
            return;
        }
        if self
            .failed_at
            .is_some_and(|t| t.elapsed() < RETRY_AFTER_FAILURE)
        {
            return;
        }

        let ours = |head: &Head| layout.screens.iter().any(|s| s.name == head.name);
        let glasses = |head: &Head| {
            is_glasses(
                &head.name,
                &format!("{} {} {}", head.make, head.model, head.description),
            )
        };

        // The rightmost real monitor's right edge, at its top
        let anchor = self
            .heads
            .values()
            .filter(|h| h.enabled && !ours(h) && !glasses(h))
            .map(|h| {
                let width = logical_widths
                    .get(&h.name)
                    .copied()
                    .unwrap_or_else(|| h.logical_size(&self.modes).0);
                (h.position.0 + width, h.position.1)
            })
            .max_by_key(|&(x, _)| x)
            .unwrap_or((0, 0));
        let (screen_positions, glasses_position) = layout.placement(anchor);

        let [width, height] = layout.resolution;
        let screen_mode = Mode {
            size: (width as i32, height as i32),
            refresh: layout.refresh as i32 * 1000,
        };
        let wanted: HashMap<&Id, Wanted> = self
            .heads
            .iter()
            .filter(|(_, h)| h.enabled)
            .filter_map(|(id, h)| {
                let wanted = if glasses(h) {
                    Wanted {
                        position: glasses_position,
                        mode: None,
                    }
                } else {
                    let index = layout.screens.iter().position(|s| s.name == h.name)?;
                    Wanted {
                        position: screen_positions[index],
                        mode: Some(screen_mode),
                    }
                };
                Some((id, wanted))
            })
            .collect();
        self.dirty = false;
        let mode_ok = |head: &Head, want: &Option<Mode>| match want {
            None => true,
            Some(want) => head.mode.and_then(|m| self.modes.get(&m)).is_some_and(|m| {
                // Refresh rates come back rounded
                m.size == want.size && (m.refresh - want.refresh).abs() < 500
            }),
        };
        let done = wanted.iter().all(|(id, want)| {
            let head = &self.heads[*id];
            head.position == want.position && mode_ok(head, &want.mode)
        });
        if done {
            return;
        }

        // Every head must appear in a configuration; unset properties keep
        // their current values.
        let config = manager.create_configuration(serial, qh, ());
        for (id, head) in &self.heads {
            let Some(proxy) = &head.proxy else { continue };
            if !head.enabled {
                config.disable_head(proxy);
                continue;
            }
            let config_head = config.enable_head(proxy, qh, ());
            if let Some(want) = wanted.get(id) {
                config_head.set_position(want.position.0, want.position.1);
                if let Some(mode) = want.mode.filter(|_| !mode_ok(head, &want.mode)) {
                    config_head.set_custom_mode(mode.size.0, mode.size.1, mode.refresh);
                }
            }
        }
        config.apply();
        self.applying = true;
    }
}

impl Dispatch<ZwlrOutputManagerV1, ()> for State {
    fn event(
        state: &mut Self,
        _: &ZwlrOutputManagerV1,
        event: zwlr_output_manager_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        let outputs = &mut state.output_layout;
        match event {
            zwlr_output_manager_v1::Event::Head { head } => {
                outputs.heads.insert(
                    head.id().protocol_id(),
                    Head {
                        proxy: Some(head),
                        scale: 1.0,
                        ..Default::default()
                    },
                );
            }
            zwlr_output_manager_v1::Event::Done { serial } => {
                outputs.serial = Some(serial);
                outputs.dirty = true;
            }
            _ => {}
        }
    }

    event_created_child!(State, ZwlrOutputManagerV1, [
        zwlr_output_manager_v1::EVT_HEAD_OPCODE => (ZwlrOutputHeadV1, ()),
    ]);
}

impl Dispatch<ZwlrOutputHeadV1, ()> for State {
    fn event(
        state: &mut Self,
        proxy: &ZwlrOutputHeadV1,
        event: zwlr_output_head_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        use zwlr_output_head_v1::Event;
        let outputs = &mut state.output_layout;
        if let Event::Finished = event {
            outputs.heads.remove(&proxy.id().protocol_id());
            return;
        }
        let Some(head) = outputs.heads.get_mut(&proxy.id().protocol_id()) else {
            return;
        };
        match event {
            Event::Name { name } => head.name = name,
            Event::Description { description } => head.description = description,
            Event::Make { make } => head.make = make,
            Event::Model { model } => head.model = model,
            Event::Enabled { enabled } => head.enabled = enabled != 0,
            Event::Position { x, y } => head.position = (x, y),
            Event::CurrentMode { mode } => head.mode = Some(mode.id().protocol_id()),
            Event::Scale { scale } => head.scale = scale,
            Event::Transform { transform } => {
                head.transform = match transform {
                    WEnum::Value(t) => t as i32,
                    WEnum::Unknown(t) => t as i32,
                };
            }
            _ => {}
        }
    }

    event_created_child!(State, ZwlrOutputHeadV1, [
        zwlr_output_head_v1::EVT_MODE_OPCODE => (ZwlrOutputModeV1, ()),
    ]);
}

impl Dispatch<ZwlrOutputModeV1, ()> for State {
    fn event(
        state: &mut Self,
        proxy: &ZwlrOutputModeV1,
        event: zwlr_output_mode_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        let modes = &mut state.output_layout.modes;
        match event {
            zwlr_output_mode_v1::Event::Size { width, height } => {
                modes.entry(proxy.id().protocol_id()).or_default().size = (width, height);
            }
            zwlr_output_mode_v1::Event::Refresh { refresh } => {
                modes.entry(proxy.id().protocol_id()).or_default().refresh = refresh;
            }
            zwlr_output_mode_v1::Event::Finished => {
                modes.remove(&proxy.id().protocol_id());
            }
            _ => {}
        }
    }
}

impl Dispatch<ZwlrOutputConfigurationV1, ()> for State {
    fn event(
        state: &mut Self,
        config: &ZwlrOutputConfigurationV1,
        event: zwlr_output_configuration_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        use zwlr_output_configuration_v1::Event;
        let outputs = &mut state.output_layout;
        match event {
            Event::Succeeded => outputs.failed_at = None,
            Event::Failed => {
                eprintln!("xr-viewer: compositor refused the output layout");
                outputs.failed_at = Some(Instant::now());
                outputs.dirty = true;
            }
            // Outputs changed meanwhile; a fresh `done` follows
            Event::Cancelled => outputs.dirty = true,
            _ => return,
        }
        outputs.applying = false;
        config.destroy();
    }
}

wayland_client::delegate_noop!(State: ignore ZwlrOutputConfigurationHeadV1);
