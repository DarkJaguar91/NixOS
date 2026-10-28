{
  flake.modules.nixos.touchscreen-outputs = {
    # The portable OLED's USB touchscreen reports no output, so the compositor
    # would map it onto the built-in panel. libinput reads WL_OUTPUT from udev
    # as the device's output; umbriel honours it when [input.touch] has no
    # global map_to_output, leaving the built-in touchscreen on eDP-1.
    # The OLED's DP connector depends on the USB-C port, and each port's USB
    # side sits on its own xHCI controller: c6:00.3 pairs with DP-1, c6:00.4
    # with DP-2.
    services.udev.extraRules = ''
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="27c0", ATTRS{idProduct}=="0868", ENV{ID_PATH}=="pci-0000:c6:00.3-*", ENV{WL_OUTPUT}="DP-1"
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="27c0", ATTRS{idProduct}=="0868", ENV{ID_PATH}=="pci-0000:c6:00.4-*", ENV{WL_OUTPUT}="DP-2"
    '';
  };
}
