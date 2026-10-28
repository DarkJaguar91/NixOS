//! The arrangement of virtual screens, shared by xr-viewer, xr-session and the
//! xr-layout editor. Screens sit on a grid: `cell = [column, row]`, columns
//! increasing to the right and rows upward, with the main screen at [0, 0]
//! (straight ahead after a recenter). The same grid sets both where each
//! screen appears around the head and where its output sits in the
//! compositor's layout, so the pointer crosses between screens the way they
//! look. All screens share one resolution so the two stay in step.

use std::collections::{HashSet, VecDeque};
use std::path::PathBuf;

use anyhow::{bail, Context as _, Result};
use serde::{Deserialize, Serialize};

pub const MAIN_CELL: [i32; 2] = [0, 0];

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Shape {
    /// Flat panels, each turned to face the viewer.
    Flat,
    /// Columns wrap around the viewer as one cylinder.
    Curved,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Screen {
    /// Name of the compositor output; letters, digits, `-`, `_` and `.`.
    pub name: String,
    pub cell: [i32; 2],
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(default)]
pub struct Layout {
    pub shape: Shape,
    /// Each screen's diagonal, as a multiple of the glasses' field of view.
    pub size: f32,
    /// Space between neighbouring screens, in degrees.
    pub gap: f32,
    pub resolution: [u32; 2],
    pub refresh: u32,
    #[serde(rename = "screen")]
    pub screens: Vec<Screen>,
}

impl Default for Layout {
    fn default() -> Self {
        Self {
            shape: Shape::Flat,
            size: 0.8,
            gap: 1.5,
            resolution: [1920, 1080],
            refresh: 60,
            screens: vec![
                Screen {
                    name: "xr".into(),
                    cell: [0, 0],
                },
                Screen {
                    name: "xr-top".into(),
                    cell: [0, 1],
                },
            ],
        }
    }
}

impl Layout {
    /// `$XDG_CONFIG_HOME/xr-session/layout.toml`.
    pub fn default_path() -> PathBuf {
        let config = std::env::var_os("XDG_CONFIG_HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| {
                PathBuf::from(std::env::var_os("HOME").unwrap_or_default()).join(".config")
            });
        config.join("xr-session/layout.toml")
    }

    /// Reads and validates a layout; a missing file gives the default.
    pub fn load(path: &std::path::Path) -> Result<Self> {
        let layout: Self = match std::fs::read_to_string(path) {
            Ok(text) => {
                toml::from_str(&text).with_context(|| format!("parsing {}", path.display()))?
            }
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => Self::default(),
            Err(err) => return Err(err).with_context(|| format!("reading {}", path.display())),
        };
        layout
            .validate()
            .with_context(|| format!("invalid layout in {}", path.display()))?;
        Ok(layout)
    }

    pub fn save(&self, path: &std::path::Path) -> Result<()> {
        self.validate()?;
        if let Some(dir) = path.parent() {
            std::fs::create_dir_all(dir)?;
        }
        let text = toml::to_string_pretty(self)?;
        std::fs::write(path, text).with_context(|| format!("writing {}", path.display()))
    }

    pub fn validate(&self) -> Result<()> {
        if !(0.1..=4.0).contains(&self.size) {
            bail!("size must be between 0.1 and 4");
        }
        if !(0.0..=20.0).contains(&self.gap) {
            bail!("gap must be between 0 and 20 degrees");
        }
        if self.resolution.iter().any(|&d| !(320..=7680).contains(&d)) {
            bail!("resolution out of range");
        }
        if !(1..=240).contains(&self.refresh) {
            bail!("refresh out of range");
        }
        let mut names = HashSet::new();
        let mut cells = HashSet::new();
        for screen in &self.screens {
            let valid = !screen.name.is_empty()
                && screen
                    .name
                    .chars()
                    .all(|c| c.is_ascii_alphanumeric() || "-_.".contains(c));
            if !valid {
                bail!("invalid screen name {:?}", screen.name);
            }
            if !names.insert(screen.name.to_ascii_lowercase()) {
                bail!("screen name {} is used twice", screen.name);
            }
            if !cells.insert(screen.cell) {
                bail!("two screens share cell {:?}", screen.cell);
            }
        }
        if !cells.contains(&MAIN_CELL) {
            bail!("there must be a main screen at [0, 0]");
        }
        if !connected(&cells) {
            bail!("every screen must share an edge with another");
        }
        Ok(())
    }

    /// Output mode in `umbriel output-create` form.
    pub fn mode(&self) -> String {
        let [w, h] = self.resolution;
        format!("{w}x{h}@{}", self.refresh)
    }

    /// A name for a new screen at `cell`, unused by this layout.
    pub fn new_name(&self, cell: [i32; 2]) -> String {
        let base = if cell == MAIN_CELL {
            "xr".to_string()
        } else {
            format!("xr.{}.{}", cell[0], cell[1])
        };
        let taken = |n: &str| self.screens.iter().any(|s| s.name.eq_ignore_ascii_case(n));
        if !taken(&base) {
            return base;
        }
        (2..)
            .map(|i| format!("{base}.{i}"))
            .find(|n| !taken(n))
            .unwrap()
    }

    /// Top-left compositor positions for each screen (in `screens` order), and
    /// for the glasses' own output, given the right edge `anchor` of the real
    /// monitors (x, and the top y of the monitor there).
    ///
    /// The leftmost column's screen nearest row 0 lands against the anchor so
    /// the pointer can reach the grid from the monitors. The glasses go just
    /// right of the rightmost screen: out of the way, but never cut off, as a
    /// pointer stranded on an isolated output can't get back.
    pub fn placement(&self, anchor: (i32, i32)) -> (Vec<(i32, i32)>, (i32, i32)) {
        let (w, h) = (self.resolution[0] as i32, self.resolution[1] as i32);
        let min_col = self.screens.iter().map(|s| s.cell[0]).min().unwrap_or(0);
        let entry_row = self
            .screens
            .iter()
            .filter(|s| s.cell[0] == min_col)
            .map(|s| s.cell[1])
            .min_by_key(|r| (r.abs(), -r))
            .unwrap_or(0);
        let positions: Vec<_> = self
            .screens
            .iter()
            .map(|s| {
                let [col, row] = s.cell;
                (
                    anchor.0 + (col - min_col) * w,
                    anchor.1 + (entry_row - row) * h,
                )
            })
            .collect();
        let glasses = positions
            .iter()
            // On a tie, beside the screen nearest the anchor's row
            .max_by_key(|&&(x, y)| (x, -(y - anchor.1).abs()))
            .map_or(anchor, |&(x, y)| (x + w, y));
        (positions, glasses)
    }
}

fn connected(cells: &HashSet<[i32; 2]>) -> bool {
    let Some(&start) = cells.iter().next() else {
        return false;
    };
    let mut seen = HashSet::from([start]);
    let mut queue = VecDeque::from([start]);
    while let Some([c, r]) = queue.pop_front() {
        for next in [[c + 1, r], [c - 1, r], [c, r + 1], [c, r - 1]] {
            if cells.contains(&next) && seen.insert(next) {
                queue.push_back(next);
            }
        }
    }
    seen.len() == cells.len()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn layout(cells: &[[i32; 2]]) -> Layout {
        let mut layout = Layout {
            screens: Vec::new(),
            ..Layout::default()
        };
        for &cell in cells {
            let name = layout.new_name(cell);
            layout.screens.push(Screen { name, cell });
        }
        layout
    }

    #[test]
    fn default_is_valid() {
        Layout::default().validate().unwrap();
    }

    #[test]
    fn rejects_disconnected_and_missing_main() {
        assert!(layout(&[[0, 0], [2, 0]]).validate().is_err());
        assert!(layout(&[[1, 0], [1, 1]]).validate().is_err());
    }

    #[test]
    fn roundtrips_through_toml() {
        let original = layout(&[[0, 0], [-1, 0], [0, 1]]);
        let text = toml::to_string_pretty(&original).unwrap();
        assert_eq!(toml::from_str::<Layout>(&text).unwrap(), original);
    }

    #[test]
    fn stacked_layout_sits_right_of_the_anchor() {
        let (positions, glasses) = Layout::default().placement((2133, 0));
        assert_eq!(positions, vec![(2133, 0), (2133, -1080)]);
        assert_eq!(glasses, (4053, 0));
    }

    #[test]
    fn left_column_enters_from_the_anchor() {
        // Main screen with one to its left and one above that
        let (positions, glasses) = layout(&[[0, 0], [-1, 0], [-1, 1]]).placement((100, 0));
        assert_eq!(positions, vec![(2020, 0), (100, 0), (100, -1080)]);
        assert_eq!(glasses, (3940, 0));
    }
}
