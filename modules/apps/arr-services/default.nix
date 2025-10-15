{
  config,
  lib,
  pkgs,
  usr,
  ...
}:
with lib;
let
  cfg = config.dj.arr-services;
in
{
  options.dj.arr-services = {
    enable = mkEnableOption "Enable Arr servies for server";
  };

  config = mkIf cfg.enable {

  };
}
