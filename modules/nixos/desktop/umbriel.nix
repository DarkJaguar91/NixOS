{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.umbriel.nixosModules.default
      ];

      # Enable Umbriel Wayland compositor
      programs.umbriel = {
        enable = true;
      };

      dots.directories.".config/umbriel" = "umbriel";
    };
}
