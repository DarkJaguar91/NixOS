# Network timezone - allow system to detect timezone from network/location
{ config, ... }:
{
  flake.nixosModules.base = {
    # Allow timezone to be determined automatically from network location
    time.timeZone = null;
  };
}
