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
  cfg = config.dj.wal;
in
{
  options.dj.wal = {
    enable = mkEnableOption "Wal color scheme manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pywal
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-wal.conf".text = ''
      L+    /home/${usr.login}/.config/wal                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/wal
    '';
  };
}
