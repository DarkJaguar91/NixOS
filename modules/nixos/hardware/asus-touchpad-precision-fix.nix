# ASUSTeK Computer Inc. GZ302EA-Keyboard touchpad (0b05:1a30).
#
# Kernel commit e716edafedad ("HID: multitouch: Check to ensure report
# responses match the request") added stricter validation of GET_FEATURE
# replies. This touchpad's firmware answers that fetch with a mismatched
# report ID, so the reply now gets discarded and the device never leaves
# fallback mode: no ABS_MT_SLOT, no ABS_MT_TOOL_TYPE, no multi-finger
# BTN_TOOL_*. Userspace then sees a plain absolute digitizer instead of a
# touchpad, which is why touching a spot on the pad warps the cursor there
# (tablet-style absolute positioning) instead of moving it relatively.
#
# Fix was accepted upstream 2026-09-11 (as commit de9eab2643b8, not yet
# synced to a public mirror or released kernel), so carry it locally until
# a nixpkgs kernel bump picks it up -- then this module and its patch can
# go away.
# https://bugzilla.kernel.org/show_bug.cgi?id=221774
{
  flake.modules.nixos.asus-touchpad-precision-fix =
    { ... }:
    {
      boot.kernelPatches = [
        {
          name = "hid-multitouch-asus-rog-z13-folio";
          patch = ./patches/hid-multitouch-asus-rog-z13-folio.patch;
        }
      ];
    };
}
