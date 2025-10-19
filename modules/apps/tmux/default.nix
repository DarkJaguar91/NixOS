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
  cfg = config.dj.tmux;
in
{
  options.dj.tmux = {
    enable = mkEnableOption "tmux Term";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tmux
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-tmux.conf".text = ''
      L+    /home/${usr.login}/.config/tmux                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/tmux
    '';
  };
}
