{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
{
  options.modules.desktop.noctalia.enable =
    lib.mkEnableOption "Noctalia shell with screenshot and recording tools";

  config = lib.mkIf config.modules.desktop.noctalia.enable {
    environment = {
      # GTK theming comes from Noctalia's gtk template: it generates color
      # CSS for GTK3/GTK4 and sets adw-gtk3-dark + prefer-dark via gsettings.
      # A GTK_THEME env var would override all of that, so don't set one.
      variables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
      };

      systemPackages = with pkgs; [
        noctalia-shell
        noctalia-qs
        nautilus
        adw-gtk3
        grim
        slurp
        swappy
        wf-recorder
        wl-clipboard
        kdePackages.breeze-icons
      ];

      etc."tmpfiles.d/home-${usr.login}-noctalia.conf".text = ''
        d  /home/${usr.login}/.config/noctalia                       0755 ${usr.login} users -
        L+ /home/${usr.login}/.config/noctalia/settings.json         -    ${usr.login} -     - ${nixConfigPath}/dots/noctalia/settings.json
        d  /home/${usr.login}/.config/swappy                         0755 ${usr.login} users -
        L+ /home/${usr.login}/.config/swappy/config                  -    ${usr.login} -     - ${nixConfigPath}/dots/swappy/config
        d  /home/${usr.login}/.config/gtk-3.0                        0755 ${usr.login} users -
        f+ /home/${usr.login}/.config/gtk-3.0/settings.ini           0644 ${usr.login} users - [Settings]\ngtk-icon-theme-name=breeze
      '';
    };
  };
}
