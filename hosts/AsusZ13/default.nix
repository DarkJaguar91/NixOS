{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  modules = {
    desktop = {
      sddm.enable = true;
      mangowc.enable = true;
      niri.enable = true;
    };
    "3d-printing".enable = true;
    ai-tools.enable = true;
    bluetooth.enable = true;
    gpu.amd.enable = true;
    kitty.enable = true;
    laptop.enable = true;
    media.enable = true;
    netbird.enable = true;
    steam.enable = true;
    steam.decky.enable = true;
  };

  networking.hostName = "AsusZ13";

  # Stable symlink + user access for the touchscreen, used by lisgd gestures
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "touchscreen-udev-rules";
      destination = "/etc/udev/rules.d/70-touchscreen.rules";
      text = ''
        SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="ELAN9008:00 04F3:43C7", SYMLINK+="input/touchscreen", TAG+="uaccess"
      '';
    })
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amdgpu.sg_display=0"
      "amdgpu.abmlevel=0"
      "amdgpu.dcdebugmask=0x600"
      "amdgpu.cwsr_enable=0"
      "iommu=pt"
    ];
  };

  hardware.sensor.iio.enable = true;

  services.handheld-daemon = {
    enable = true;
    user = "brandon";
    adjustor.enable = true;
  };

  environment.systemPackages = with pkgs; [
    handheld-daemon-ui
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
