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
  cfg = config.dj.cava;
in
{
  options.dj.cava = {
    enable = mkEnableOption "cava Term";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cava
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-cava.conf".text = ''
      L+    /home/${usr.login}/.config/cava                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/cava
    '';
  };
}
