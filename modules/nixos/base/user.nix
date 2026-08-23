# User configuration - part of base
{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      users.users.${owner.username} = {
        isNormalUser = true;
        description = owner.name;
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.fish;
      };
    };
}
