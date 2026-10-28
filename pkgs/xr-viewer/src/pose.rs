//! Head pose from XRLinuxDriver. The driver publishes System V shared memory
//! segments keyed with ftok() on /tmp/shader_runtime_<name> files, which it
//! creates when the glasses connect.

use std::ffi::CString;
use std::time::{Duration, Instant};

use glam::Quat;

const PREFIX: &str = "/tmp/shader_runtime_";
const RETRY: Duration = Duration::from_secs(1);
/// The driver updates the pose at the IMU rate (60Hz or more) even when the
/// head is still; this long without a new sample means tracking is lost.
const STALE: Duration = Duration::from_millis(250);

/// Attached `pose_orientation` segment: 16 floats, where [0..4] is the latest
/// orientation quaternion (x, y, z, w) in NWU (x forward, y left, z up),
/// relative to the pose the driver last centered on, and [12] its timestamp
/// in milliseconds.
pub struct PoseReader {
    pose: Option<*const f32>,
    disabled: Option<*const u8>,
    last_attempt: Option<Instant>,
    /// Latest sample timestamp, and when it was first seen.
    last_sample: Option<(f32, Instant)>,
    /// Whether a new sample has landed since attaching; until then the
    /// segment may be a dead driver's frozen last pose.
    live: bool,
}

impl PoseReader {
    pub fn new() -> Self {
        Self {
            pose: None,
            disabled: None,
            last_attempt: None,
            last_sample: None,
            live: false,
        }
    }

    /// Latest head orientation, or None while the driver isn't publishing.
    pub fn orientation(&mut self) -> Option<Quat> {
        if self.pose.is_none() {
            self.try_attach();
        }
        let pose = self.pose?;
        if let Some(disabled) = self.disabled {
            if unsafe { disabled.read_volatile() } != 0 {
                return None;
            }
        }
        let timestamp = unsafe { pose.add(12).read_volatile() };
        let now = Instant::now();
        match self.last_sample {
            Some((last, _)) if last != timestamp => {
                self.last_sample = Some((timestamp, now));
                self.live = true;
            }
            Some((_, seen)) if now - seen > STALE => {
                // A restarted driver recreates its segments, leaving ours
                // orphaned; reattach to pick up the new ones.
                self.detach();
                return None;
            }
            Some(_) => {}
            None => self.last_sample = Some((timestamp, now)),
        }
        if !self.live {
            return None;
        }

        // The driver guards writes with a mutex that isn't process-shared, so
        // read the four floats directly; a torn read lasts one frame at most.
        let q = unsafe { std::array::from_fn::<f32, 4, _>(|i| pose.add(i).read_volatile()) };
        let quat = Quat::from_xyzw(q[0], q[1], q[2], q[3]);
        // All zeroes until the driver finishes calibrating
        (quat.length_squared() > 0.5).then(|| quat.normalize())
    }

    fn detach(&mut self) {
        for ptr in [
            self.pose.take().map(|p| p.cast()),
            self.disabled.take().map(|p| p.cast()),
        ]
        .into_iter()
        .flatten()
        {
            unsafe { libc::shmdt(ptr) };
        }
        self.last_sample = None;
        self.live = false;
    }

    fn try_attach(&mut self) {
        if self.last_attempt.is_some_and(|t| t.elapsed() < RETRY) {
            return;
        }
        self.last_attempt = Some(Instant::now());
        self.pose = attach("pose_orientation", 16 * 4).map(|p| p as *const f32);
        self.disabled = attach("disabled", 1).map(|p| p as *const u8);
    }
}

fn attach(name: &str, size: usize) -> Option<*const libc::c_void> {
    let path = CString::new(format!("{PREFIX}{name}")).ok()?;
    unsafe {
        let key = libc::ftok(path.as_ptr(), 0);
        if key == -1 {
            return None;
        }
        let id = libc::shmget(key, size, 0);
        if id == -1 {
            return None;
        }
        let ptr = libc::shmat(id, std::ptr::null(), libc::SHM_RDONLY);
        (ptr as isize != -1).then_some(ptr as *const libc::c_void)
    }
}
