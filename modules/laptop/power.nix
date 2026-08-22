{ config, pkgs, lib, ... }:

{
  # Enable power management
  powerManagement.enable = true;

  # Laptop-specific TLP for power saving
  services.tlp = {
    enable = lib.mkDefault true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # TLP conflicts with power-profiles-daemon
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Compress RAM instead of swapping to SSD
  zramSwap.enable = true;
}
