{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
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
      L+    /home/${usr.login}/.config/rofi                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/rofi
    '';
  };
}
