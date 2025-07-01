{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.asus-flow-gv302x-amdgpu
  ];

  hardware.asus.flow.gv302x = {
    keyboard.autosuspend.enable = true;
    ite-device.wakeup.enable = true;
    amdgpu = {
      recovery.enable = false;
      sg_display.enable = true;
      psr.enable = true;
    };
  };

  # Wifi fixes - sometimes works
  networking.wireless.iwd.enable = true;
  networking.wireless.scanOnLowSignal = false;
}
