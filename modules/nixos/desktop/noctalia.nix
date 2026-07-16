# Noctalia shell (bar, launcher, notifications, lock screen), latest from its
# flake, running as a systemd user service bound to the niri session.
# Its settings (~/.config/noctalia) are runtime state managed through its own
# UI — deliberately not symlinked into this repo.
{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = [ inputs.noctalia.nixosModules.default ];

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

        # file manager (pairs with gvfs for browsing USB drives)
        nautilus

        # noctalia's gtk template targets adw-gtk3; breeze fills in icons
        adw-gtk3
        kdePackages.breeze-icons
      ];

      # backend for noctalia's screen recorder (control center)
      programs.gpu-screen-recorder.enable = true;

      # Noctalia's gtk template generates color CSS and sets adw-gtk3-dark via
      # gsettings; a GTK_THEME env var would override all of that, so only the
      # Qt side is pointed at gtk theming here.
      environment.variables.QT_QPA_PLATFORMTHEME = "gtk3";
      programs.dconf.enable = true;

      dots.files.".config/gtk-3.0/settings.ini" = "gtk-3.0/settings.ini";
    };
}
