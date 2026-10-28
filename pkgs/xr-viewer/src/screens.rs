//! The virtual outputs behind the screens, and the layout file they follow.
//! The viewer creates and destroys outputs as the layout changes, and records
//! which exist so xr-session can remove them even if the viewer dies.

use std::path::PathBuf;
use std::process::Command;
use std::time::{Duration, Instant, SystemTime};

use xr_viewer::layout::Layout;

/// How often to look for changes to the layout file.
const POLL: Duration = Duration::from_millis(300);

pub fn create(name: &str, mode: &str) {
    run(Command::new("umbriel").args(["output-create", name, mode]));
}

pub fn destroy(name: &str) {
    run(Command::new("umbriel").args(["output-destroy", name]));
}

fn run(command: &mut Command) {
    match command.output() {
        Ok(out) if out.status.success() => {}
        Ok(out) => eprintln!(
            "xr-viewer: {:?} failed: {}",
            command,
            String::from_utf8_lossy(&out.stderr).trim()
        ),
        Err(err) => eprintln!("xr-viewer: running {command:?}: {err}"),
    }
}

/// `$XDG_RUNTIME_DIR/xr-session.screens`: one output name per line.
pub fn record_path() -> Option<PathBuf> {
    std::env::var_os("XDG_RUNTIME_DIR").map(|dir| PathBuf::from(dir).join("xr-session.screens"))
}

pub fn record(layout: &Layout) {
    let Some(path) = record_path() else { return };
    let names: String = layout
        .screens
        .iter()
        .map(|s| format!("{}\n", s.name))
        .collect();
    if let Err(err) = std::fs::write(&path, names) {
        eprintln!("xr-viewer: writing {}: {err}", path.display());
    }
}

/// Notices when the layout file is saved and reloads it.
pub struct LayoutWatcher {
    path: PathBuf,
    stamp: Option<(SystemTime, u64)>,
    checked: Instant,
}

impl LayoutWatcher {
    pub fn new(path: PathBuf) -> Self {
        let stamp = stamp(&path);
        Self {
            path,
            stamp,
            checked: Instant::now(),
        }
    }

    /// The new layout, if the file changed since the last call and parses.
    /// An invalid save is reported and skipped; the screens stay as they are.
    pub fn poll(&mut self) -> Option<Layout> {
        if self.checked.elapsed() < POLL {
            return None;
        }
        self.checked = Instant::now();
        let stamp = stamp(&self.path);
        if stamp == self.stamp {
            return None;
        }
        self.stamp = stamp;
        match Layout::load(&self.path) {
            Ok(layout) => Some(layout),
            Err(err) => {
                eprintln!("xr-viewer: keeping the current layout: {err:#}");
                None
            }
        }
    }
}

fn stamp(path: &std::path::Path) -> Option<(SystemTime, u64)> {
    // Follows the symlink into the dotfiles checkout
    let meta = std::fs::metadata(path).ok()?;
    Some((meta.modified().ok()?, meta.len()))
}
