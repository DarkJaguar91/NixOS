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

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
