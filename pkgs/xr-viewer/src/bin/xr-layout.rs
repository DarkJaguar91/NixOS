//! xr-layout: edits the xr-session screen layout. Click an empty cell next to
//! a screen to add one there, or a screen to remove it; the main screen (the
//! one straight ahead after a recenter) stays put. A running session follows
//! the file as it's saved; in live mode every change is saved as you make it.

use std::path::PathBuf;
use std::time::{Duration, Instant};

use eframe::egui;
use xr_viewer::layout::{Layout, Screen, Shape, MAIN_CELL};

/// Columns and rows shown either side of the main screen.
const GRID_REACH: [i32; 2] = [3, 2];
const RESOLUTIONS: [[u32; 2]; 3] = [[1280, 720], [1920, 1080], [2560, 1440]];
const REFRESH_RATES: [u32; 3] = [60, 90, 120];
/// In live mode, how long a change must hold before it's saved, so dragging a
/// slider doesn't rebuild the screens on every step.
const LIVE_DELAY: Duration = Duration::from_millis(350);

fn main() -> eframe::Result {
    let path = std::env::args_os()
        .nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(Layout::default_path);
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_app_id("xr-layout")
            .with_title("XR screen layout")
            .with_inner_size([760.0, 620.0]),
        ..Default::default()
    };
    eframe::run_native(
        "xr-layout",
        options,
        Box::new(move |_| Ok(Box::new(Editor::new(path)))),
    )
}

struct Editor {
    path: PathBuf,
    layout: Layout,
    /// What the file holds.
    saved: Layout,
    /// What the file held when the editor opened, for undoing live changes.
    original: Layout,
    live: bool,
    /// A live change waiting out LIVE_DELAY.
    pending: Option<(Layout, Instant)>,
    status: Option<(String, bool)>,
}

impl Editor {
    fn new(path: PathBuf) -> Self {
        let (layout, status) = match Layout::load(&path) {
            Ok(layout) => (layout, None),
            Err(err) => (
                Layout::default(),
                Some((format!("{err:#}; starting from the default"), true)),
            ),
        };
        Self {
            path,
            saved: layout.clone(),
            original: layout.clone(),
            layout,
            live: true,
            pending: None,
            status,
        }
    }

    fn screen_at(&self, cell: [i32; 2]) -> Option<usize> {
        self.layout.screens.iter().position(|s| s.cell == cell)
    }

    fn has_neighbour(&self, [c, r]: [i32; 2]) -> bool {
        [[c + 1, r], [c - 1, r], [c, r + 1], [c, r - 1]]
            .iter()
            .any(|&n| self.screen_at(n).is_some())
    }

    fn click(&mut self, cell: [i32; 2]) {
        match self.screen_at(cell) {
            Some(_) if cell == MAIN_CELL => {
                self.status = Some(("The main screen can't be removed".into(), true));
            }
            Some(index) => {
                let mut candidate = self.layout.clone();
                candidate.screens.remove(index);
                match candidate.validate() {
                    Ok(()) => {
                        self.layout = candidate;
                        self.status = None;
                    }
                    Err(_) => {
                        self.status = Some((
                            "Removing that screen would cut others off from the main screen".into(),
                            true,
                        ));
                    }
                }
            }
            None if self.has_neighbour(cell) => {
                let name = self.layout.new_name(cell);
                self.layout.screens.push(Screen { name, cell });
                self.status = None;
            }
            None => {
                self.status = Some(("New screens must touch an existing one".into(), true));
            }
        }
    }

    fn save(&mut self, running: bool) {
        if let Err(err) = self.layout.save(&self.path) {
            self.status = Some((format!("Couldn't save: {err:#}"), true));
            return;
        }
        self.saved = self.layout.clone();
        self.pending = None;
        let note = if running {
            "Saved; the running session has it"
        } else {
            "Saved; the next session uses it"
        };
        self.status = Some((note.into(), false));
    }

    /// In live mode, saves once a change has held still for LIVE_DELAY.
    fn save_live(&mut self, ctx: &egui::Context) {
        if self.layout == self.saved || self.layout.validate().is_err() {
            self.pending = None;
            return;
        }
        match &self.pending {
            Some((layout, since)) if *layout == self.layout => {
                if since.elapsed() >= LIVE_DELAY {
                    self.save(true);
                } else {
                    ctx.request_repaint_after(LIVE_DELAY - since.elapsed());
                }
            }
            _ => {
                self.pending = Some((self.layout.clone(), Instant::now()));
                ctx.request_repaint_after(LIVE_DELAY);
            }
        }
    }

    fn settings(&mut self, ui: &mut egui::Ui) {
        egui::Grid::new("settings")
            .num_columns(2)
            .spacing([16.0, 8.0])
            .show(ui, |ui| {
                ui.label("Shape");
                ui.horizontal(|ui| {
                    ui.selectable_value(&mut self.layout.shape, Shape::Flat, "Flat")
                        .on_hover_text("Flat panels, each turned to face you");
                    ui.selectable_value(&mut self.layout.shape, Shape::Curved, "Curved")
                        .on_hover_text("Columns wrap around you as one curved surface");
                });
                ui.end_row();

                ui.label("Screen size");
                ui.add(
                    egui::Slider::new(&mut self.layout.size, 0.3..=1.5)
                        .step_by(0.05)
                        .custom_formatter(|v, _| format!("{:.0}% of view", v * 100.0)),
                );
                ui.end_row();

                ui.label("Gap");
                ui.add(
                    egui::Slider::new(&mut self.layout.gap, 0.0..=10.0)
                        .step_by(0.5)
                        .suffix("°"),
                );
                ui.end_row();

                ui.label("Resolution");
                egui::ComboBox::from_id_salt("resolution")
                    .selected_text(format!(
                        "{}×{}",
                        self.layout.resolution[0], self.layout.resolution[1]
                    ))
                    .show_ui(ui, |ui| {
                        for res in RESOLUTIONS {
                            ui.selectable_value(
                                &mut self.layout.resolution,
                                res,
                                format!("{}×{}", res[0], res[1]),
                            );
                        }
                    });
                ui.end_row();

                ui.label("Refresh rate");
                egui::ComboBox::from_id_salt("refresh")
                    .selected_text(format!("{} Hz", self.layout.refresh))
                    .show_ui(ui, |ui| {
                        for rate in REFRESH_RATES {
                            ui.selectable_value(
                                &mut self.layout.refresh,
                                rate,
                                format!("{rate} Hz"),
                            );
                        }
                    });
                ui.end_row();
            });
    }

    fn grid(&mut self, ui: &mut egui::Ui) {
        let [reach_c, reach_r] = GRID_REACH;
        let (cols, rows) = (2 * reach_c + 1, 2 * reach_r + 1);
        let aspect = self.layout.resolution[1] as f32 / self.layout.resolution[0] as f32;
        let spacing = 6.0;
        let width = ui.available_width();
        let cell_w = ((width - spacing * (cols - 1) as f32) / cols as f32).min(110.0);
        let cell_h = cell_w * aspect;
        let size = egui::vec2(
            cell_w * cols as f32 + spacing * (cols - 1) as f32,
            cell_h * rows as f32 + spacing * (rows - 1) as f32,
        );
        let (area, _) = ui.allocate_exact_size(size, egui::Sense::hover());
        let visuals = ui.visuals().clone();

        let mut clicked = None;
        for row in (-reach_r..=reach_r).rev() {
            for col in -reach_c..=reach_c {
                let cell = [col, row];
                let min = area.min
                    + egui::vec2(
                        (col + reach_c) as f32 * (cell_w + spacing),
                        (reach_r - row) as f32 * (cell_h + spacing),
                    );
                let rect = egui::Rect::from_min_size(min, egui::vec2(cell_w, cell_h));
                let response = ui.interact(rect, ui.scope_id().with(cell), egui::Sense::click());
                let painter = ui.painter();
                let rounding = 4.0;

                match self.screen_at(cell) {
                    Some(index) => {
                        let main = cell == MAIN_CELL;
                        let fill = if main {
                            visuals.selection.bg_fill
                        } else {
                            visuals.widgets.inactive.bg_fill
                        };
                        let fill = if response.hovered() && !main {
                            visuals.widgets.hovered.bg_fill
                        } else {
                            fill
                        };
                        painter.rect_filled(rect, rounding, fill);
                        let label = if main {
                            "main"
                        } else {
                            self.layout.screens[index].name.as_str()
                        };
                        painter.text(
                            rect.center(),
                            egui::Align2::CENTER_CENTER,
                            label,
                            egui::FontId::proportional(12.0),
                            visuals.strong_text_color(),
                        );
                        let response = if main {
                            response.on_hover_text("Straight ahead after a recenter")
                        } else {
                            response.on_hover_text("Click to remove")
                        };
                        if response.clicked() {
                            clicked = Some(cell);
                        }
                    }
                    None => {
                        let addable = self.has_neighbour(cell);
                        let stroke = if addable && response.hovered() {
                            visuals.widgets.hovered.fg_stroke
                        } else {
                            egui::Stroke::new(1.0, visuals.widgets.noninteractive.bg_stroke.color)
                        };
                        painter.rect_stroke(rect, rounding, stroke, egui::StrokeKind::Inside);
                        if addable {
                            painter.text(
                                rect.center(),
                                egui::Align2::CENTER_CENTER,
                                "+",
                                egui::FontId::proportional(18.0),
                                visuals.weak_text_color(),
                            );
                            if response.on_hover_text("Click to add a screen").clicked() {
                                clicked = Some(cell);
                            }
                        }
                    }
                }
            }
        }
        if let Some(cell) = clicked {
            self.click(cell);
        }
    }
}

fn session_running() -> bool {
    let Some(runtime) = std::env::var_os("XDG_RUNTIME_DIR") else {
        return false;
    };
    let pidfile = PathBuf::from(runtime).join("xr-session.pid");
    std::fs::read_to_string(pidfile)
        .ok()
        .and_then(|pid| pid.trim().parse::<i32>().ok())
        .is_some_and(|pid| unsafe { libc::kill(pid, 0) } == 0)
}

impl eframe::App for Editor {
    fn ui(&mut self, ui: &mut egui::Ui, _: &mut eframe::Frame) {
        let running = session_running();
        let live = running && self.live;
        egui::CentralPanel::default().show(ui, |ui| {
            ui.heading("XR screen layout");
            ui.label("Seen from where you sit: up is up, right is right.");
            ui.add_space(8.0);
            self.settings(ui);
            ui.add_space(12.0);
            self.grid(ui);
            ui.add_space(12.0);

            let changed = self.layout != self.saved;
            ui.horizontal(|ui| {
                if running {
                    ui.checkbox(&mut self.live, "Live")
                        .on_hover_text("Apply each change to the running session as you make it");
                }
                if !live && ui.add_enabled(changed, egui::Button::new("Save")).clicked() {
                    self.save(running);
                }
                if ui
                    .add_enabled(
                        self.layout != self.original,
                        egui::Button::new("Undo changes"),
                    )
                    .on_hover_text("Back to the layout as it was when this window opened")
                    .clicked()
                {
                    self.layout = self.original.clone();
                    self.status = None;
                }
                if ui.button("Reset to default").clicked() {
                    self.layout = Layout::default();
                    self.status = None;
                }
            });
            if let Some((text, error)) = &self.status {
                let color = if *error {
                    ui.visuals().error_fg_color
                } else {
                    ui.visuals().weak_text_color()
                };
                ui.colored_label(color, text);
            }
            ui.add_space(4.0);
            ui.small(self.path.display().to_string());
        });
        if live {
            self.save_live(ui.ctx());
        }
    }
}
