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
  cfg = config.dj.yazi;
in
{
  options.dj.yazi = {
    enable = mkEnableOption "Yazi termrinal file browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yazi
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-yazi.conf".text = ''
      L+    /home/${usr.login}/.config/yazi                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/yazi
    '';
  };
}
