{
  config,
  lib,
  usr,
  nixConfigPath,
  ...
}:
with lib;
let
  cfg = config.dj.waybar;
in
{
  options.dj.waybar = {
    enable = mkEnableOption "Waybar wayland status bar";
  };

  config = mkIf cfg.enable {
    programs = {
      waybar.enable = true;
    };

    environment.etc."tmpfiles.d/home-${usr.login}-waybar.conf".text = ''
      L+    /home/${usr.login}/.config/waybar                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/waybar
    '';
  };
}
