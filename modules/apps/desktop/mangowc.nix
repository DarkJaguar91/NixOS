{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
{
  options.modules.desktop.mangowc.enable =
    lib.mkEnableOption "MangoWC Wayland compositor with Noctalia shell";

  config = lib.mkIf config.modules.desktop.mangowc.enable {
    programs.mangowc.enable = true;

    environment.systemPackages = with pkgs; [
      noctalia-shell
      noctalia-qs
      grim
      slurp
      swappy
      wf-recorder
      wl-clipboard
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-mango.conf".text = ''
      d  /home/${usr.login}/.config/mango                          0755 ${usr.login} users -
      L+ /home/${usr.login}/.config/mango/config.conf              -    ${usr.login} -     - ${nixConfigPath}/dots/mango/config.conf
      L+ /home/${usr.login}/.config/mango/style.conf               -    ${usr.login} -     - ${nixConfigPath}/dots/mango/style.conf
      L+ /home/${usr.login}/.config/mango/animations.conf          -    ${usr.login} -     - ${nixConfigPath}/dots/mango/animations.conf
      L+ /home/${usr.login}/.config/mango/keybinds.conf            -    ${usr.login} -     - ${nixConfigPath}/dots/mango/keybinds.conf
      L+ /home/${usr.login}/.config/mango/rules.conf               -    ${usr.login} -     - ${nixConfigPath}/dots/mango/rules.conf
      d  /home/${usr.login}/.config/noctalia                       0755 ${usr.login} users -
      L+ /home/${usr.login}/.config/noctalia/settings.json         -    ${usr.login} -     - ${nixConfigPath}/dots/noctalia/settings.json
    '';
  };
}
