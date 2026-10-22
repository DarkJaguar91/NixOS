{ config, inputs, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.desktop = {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    services.displayManager.noctalia-greeter = {
      enable = true;
      # Let Noctalia auto-sync wallpaper/palette to the greeter without a polkit prompt
      passwordless-sync-users = [ owner.username ];
      settings = {
        session.default = "umbriel";
        appearance = {
          scheme = "Synced";
          password_style = "default";
        };
        cursor = {
          # must be installed system-wide (apps.nix); matches the session
          theme = "breeze_cursors";
          size = 24;
        };
        keyboard = {
          layout = "us";
        };
      };
    };

    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };
    users.groups.greeter = { };
  };
}
