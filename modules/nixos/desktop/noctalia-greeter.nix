{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      programs.noctalia-greeter = {
        enable = true;
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
      users.groups.greeter = {};
    };
}
