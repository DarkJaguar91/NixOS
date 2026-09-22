{
  flake.modules.nixos.asus-copilot-key = {
    services.keyd = {
      enable = true;
      keyboards.asus-copilot-key = {
        # ASUSTeK Computer Inc. GZ302EA-Keyboard (Vendor 0b05, Product 1a30).
        # The "Copilot" key doesn't send its own keycode: the firmware fakes
        # Super+Shift+F23 (Windows' convention for OEM Copilot keys). Collapse
        # that chord down to a single plain Right Control instead. Left
        # Meta/Shift keep working normally on their own since only the
        # composite (both-held) case is touched.
        #
        # The bare "0b05:1a30" id matches *every* HID sub-interface sharing
        # that vendor:product, not just the keyboard: this same USB
        # interface also exposes a "Mouse" and a "Touchpad" input node (see
        # `journalctl -u keyd` -> "DEVICE: match ... GZ302EA-Keyboard
        # Touchpad/Mouse"). keyd grabbed those too and relayed the
        # touchpad's ABS multitouch data through its own virtual pointer as
        # absolute coordinates, making the touchpad behave like a graphics
        # tablet (touch a spot -> cursor warps there) instead of a normal
        # relative pointer.
        #
        # Pin the exact per-interface ids (vendor:product:hash, from
        # `journalctl -u keyd`) for just the two keyboard-capable
        # interfaces, so keyd leaves the touchpad/mouse interfaces alone
        # and libinput handles them normally. The hash is a deterministic
        # djb2 over the device's name + key count + abs/rel capability
        # masks (keyd src/device.c generate_uid()), so it's stable across
        # reboots for this same physical hardware/firmware.
        ids = [
          "0b05:1a30:00a3d98c" # GZ302EA-Keyboard (key matrix)
          "0b05:1a30:09ed1c53" # GZ302EA-Keyboard (consumer control / Fn hotkeys, incl. Copilot's fake F23)
        ];
        settings = {
          main = { };
          leftmeta = { };
          leftshift = { };
          "leftmeta+leftshift" = {
            f23 = "rightcontrol";
          };
        };
      };
    };
  };
}
