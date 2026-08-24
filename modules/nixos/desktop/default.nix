# Desktop environment - Noctalia ecosystem (Umbriel + Noctalia shell + Noctalia greeter)
{ inputs, ... }:
{
  flake.nixosModules.desktop =
    { pkgs, lib, ... }:
    {
      imports = [
        # Import the flake modules
        inputs.noctalia.nixosModules.default
        inputs.noctalia-greeter.nixosModules.default
        inputs.umbriel.nixosModules.default
        inputs.self.nixosModules.gaming
      ];

      # Enable Umbriel Wayland compositor
      programs.umbriel = {
        enable = true;
      };

      # Enable Noctalia desktop shell
      programs.noctalia = {
        enable = true;
        systemd = {
          enable = true;
          target = "umbriel-session.target";
        };
        recommendedServices.enable = true;
      };

      # Enable Noctalia Greeter (login screen)
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

      # Create greeter user for noctalia-greeter
      users.users.greeter = {
        isSystemUser = true;
        group = "greeter";
      };
      users.groups.greeter = {};

      # Enable dconf so gsettings works properly
      programs.dconf.enable = true;

      # Desktop applications
      environment.systemPackages = with pkgs; [
        adw-gtk3                    # GTK theme base for Noctalia dark mode
        glib                        # provides gsettings binary
        gsettings-desktop-schemas   # GNOME settings schemas for gsettings color-scheme
        qt6Packages.qt6ct            # Qt6 theme configurator
        libsForQt5.qt5ct             # Qt5 theme configurator
        gh                          # GitHub CLI for PRs/issues
        kitty                       # Terminal
        firefox                     # Browser
        wf-recorder                 # Screen recorder for Wayland
        brightnessctl               # Backlight control for brightness keys
      ];

      # Set kitty as default terminal
      environment.variables.TERMINAL = "kitty";

      # Make gsettings schemas discoverable for GTK app theming
      environment.sessionVariables.GSETTINGS_SCHEMA_DIR =
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

      # Dotfiles: umbriel config and noctalia settings are symlinked from the
      # flake repo so they stay editable by Noctalia's UI and runtime tools.
      dots.directories.".config/umbriel" = "umbriel";
      dots.files.".local/state/noctalia/settings.toml" = "noctalia/settings.toml";
    };
}
