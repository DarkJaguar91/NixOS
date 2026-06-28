{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  modules = {
    bluetooth.enable = true;
    desktop = {
      enable = true;
      displayManager = "sddm";
      plasma.enable = true;
    };
    gaming.enable = true;
    gpu.amd.enable = true;
    media.enable = true;
    social.enable = true;
  };

  networking.hostName = "DarkJaguar";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/storage" = {
    device = "/dev/disk/by-uuid/c6ad7265-5c71-4fe1-85a9-4e5e77282909";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
    ];
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
