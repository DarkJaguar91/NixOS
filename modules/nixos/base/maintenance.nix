# System maintenance - part of base
{ config, ... }:
{
  flake.nixosModules.base =
    { ... }:
    {
      # Enable SSD TRIM
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };

      # Enable SMART disk monitoring
      services.smartd = {
        enable = true;
        notifications = {
          # Notify all users on the system (if any are logged in)
          wall.enable = true;
          # Send emails for serious issues (requires mail setup, disabled by default)
          mail = {
            enable = false;
            recipient = "root";
          };
        };
      };

      # Enable non-free firmware for hardware not recognized by nixos-generate-config
      # This covers microcode updates, wifi firmware, etc.
      hardware.enableRedistributableFirmware = true;
    };
}
