# Network configuration - part of base
{ config, ... }:
{
  flake.nixosModules.base =
    { ... }:
    {
      networking.networkmanager.enable = true;

      # Enable firewall
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };
    };
}
