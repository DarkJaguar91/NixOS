{
  config,
  lib,
  pkgs,
  usr,
  ...
}:
with lib;
let
  cfg = config.dj.plex-server;
in
{
  options.dj.plex-server = {
    enable = mkEnableOption "Enable plex server";
  };

  config = mkIf cfg.enable {

  };
}
