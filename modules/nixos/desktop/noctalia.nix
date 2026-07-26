# Noctalia shell (bar, launcher, notifications, lock screen), latest from its
# flake, running as a systemd user service bound to the niri session.
# Its settings file is symlinked into this repo so UI changes land in the
# checkout and sync between hosts; the rest of ~/.local/state/noctalia
# (caches, notification history) stays runtime-only.
{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      # game-launcher plugin hardcodes /usr/bin/cc (a Debian-ism) to build its
      # scanner against libsqlite3; NixOS has no /usr/bin/cc and plain gcc
      # doesn't see sqlite's headers/lib, so this symlink target wraps gcc
      # with both baked in.
      gamelauncherCc = pkgs.writeShellScript "gamelauncher-cc" ''
        exec ${pkgs.gcc}/bin/gcc \
          -I${pkgs.sqlite.dev}/include \
          -L${pkgs.sqlite.out}/lib \
          -Wl,-rpath,${pkgs.sqlite.out}/lib \
          "$@"
      '';
    in
    {
      imports = [ inputs.noctalia.nixosModules.default ];

      systemd.tmpfiles.rules = [
        "L+ /usr/bin/cc - - - - ${gamelauncherCc}"
      ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        # pulls in upower + power-profiles-daemon for the battery/power widgets
        recommendedServices.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # clipboard history + brightness backends for noctalia widgets
        cliphist
        wl-clipboard
        brightnessctl

        # region selection for the record-region keybind (dotfiles/niri/scripts)
        slurp

        # backends for noctalia's mpvpaper plugin (video/gif wallpapers);
        # plugin itself is enabled via Noctalia's Settings UI, not Nix
        mpvpaper
        mpv

        # noctalia's gtk template targets adw-gtk3; breeze fills in icons
        adw-gtk3
        kdePackages.breeze-icons
      ];

      # file manager (pairs with gvfs for browsing USB drives); xfconf
      # persists its settings, tumbler renders thumbnails
      programs.thunar.enable = true;
      programs.xfconf.enable = true;
      services.tumbler.enable = true;

      # backend for noctalia's screen recorder (control center)
      programs.gpu-screen-recorder.enable = true;

      # Noctalia's gtk template generates color CSS and sets adw-gtk3-dark via
      # gsettings; a GTK_THEME env var would override all of that, so only the
      # Qt side is pointed at gtk theming here.
      environment.variables.QT_QPA_PLATFORMTHEME = "gtk3";
      programs.dconf.enable = true;

      dots.files.".config/gtk-3.0/settings.ini" = "gtk-3.0/settings.ini";
      dots.files.".local/state/noctalia/settings.toml" = "noctalia/settings.toml";
    };
}
