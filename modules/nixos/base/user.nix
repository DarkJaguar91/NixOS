{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      users.users.${owner.username} = {
        isNormalUser = true;
        description = owner.name;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.fish;
      };

      security.sudo.wheelNeedsPassword = false;
    };
}
