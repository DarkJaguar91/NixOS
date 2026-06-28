{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  modules.bluetooth.enable = true;
  modules.desktop.enable = true;
  modules.gaming.enable = true;
  modules.gpu.amd.enable = true;
  modules.media.enable = true;
  modules.social.enable = true;

  networking.hostName = "DarkJaguar";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
