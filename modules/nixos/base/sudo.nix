# Sudo configuration - wheel users don't need password
{ config, ... }:
{
  flake.nixosModules.base = {
    security.sudo.wheelNeedsPassword = false;
  };
}
