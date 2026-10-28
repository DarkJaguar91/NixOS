//! A frame being received through wlr-export-dmabuf: the compositor sends the
//! layout first, then one event per dmabuf plane, then ready or cancel.

use std::os::fd::OwnedFd;

pub struct Plane {
    pub fd: OwnedFd,
    pub offset: u32,
    pub stride: u32,
}

#[derive(Default)]
pub struct DmabufFrame {
    pub width: u32,
    pub height: u32,
    pub format: u32,
    pub modifier: u64,
    pub y_invert: bool,
    pub planes: Vec<Option<Plane>>,
}

impl DmabufFrame {
    pub fn complete(&self) -> bool {
        !self.planes.is_empty() && self.planes.iter().all(Option::is_some)
    }
}
