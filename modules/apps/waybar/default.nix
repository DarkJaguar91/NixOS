{
  config,
  lib,
  usr,
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
      L+    /home/${usr.login}/.config/waybar                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/waybar
    '';
  };
}
