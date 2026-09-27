{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      services.displayManager.noctalia-greeter = {
        enable = true;
        # Let Noctalia auto-sync wallpaper/palette to the greeter without a polkit prompt
        passwordless-sync-users = [ "brandon" ];
        settings = {
          session.default = "umbriel";
          appearance = {
            scheme = "Synced";
            password_style = "default";
          };
          cursor = {
            theme = "Adwaita";
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
