{
  config,
  lib,
  pkgs,
  usr,
  ...
}:
with lib;
let
  cfg = config.dj.rofi;
in
{
  options.dj.rofi = {
    enable = mkEnableOption "Rofi application launcher";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rofi
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-rofi.conf".text = ''
      L+    /home/${usr.login}/.config/rofi                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/rofi
    '';
  };
}
