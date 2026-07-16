{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.base = {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = owner.name;
          email = owner.email;
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
  };
}
