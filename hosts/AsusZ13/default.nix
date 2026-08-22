{ config, pkgs, lib, ... }:

let
  dendritic = import ../../lib/dendritic.nix {
    inherit lib;
    modulesPath = ../../modules;
  };
in
{
  imports = dendritic.load [ "common" "laptop" "desktop" "3dprinting" ] ++ [
    ./hardware-configuration.nix
  ];

  networking.hostName = "AsusZ13";

  # Swap LUKS device is referenced in hardware-configuration.nix but not unlocked at boot
  boot.initrd.luks.devices."luks-8ff9e3ed-9e9f-4929-b3ac-face66162ada".device =
    "/dev/disk/by-uuid/8ff9e3ed-9e9f-4929-b3ac-face66162ada";

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

  # orientation sensor
  hardware.sensor.iio.enable = true;
  
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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.handheld-daemon = {
    enable = true;
    user = "brandon";
    ui.enable = true;
    adjustor.enable = true;
  };

  system.stateVersion = "24.11";
}
