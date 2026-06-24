{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  modules.bluetooth.enable = true;
  modules.desktop.enable = true;
  modules.gaming.enable = true;
  modules.gpu.amd.enable = true;
  modules.laptop.enable = true;
  modules.media.enable = true;
  modules.social.enable = true;

  networking.hostName = "AsusZ13";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.sensor.iio.enable = true;

  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.abmlevel=0"
    "amdgpu.dcdebugmask=0x600"
    "amdgpu.cwsr_enable=0"
    "iommu=pt"
  ];

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "brandon";
  services.handheld-daemon.adjustor.enable = true;

  environment.systemPackages = with pkgs; [
    handheld-daemon-ui
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
