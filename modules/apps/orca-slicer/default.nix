{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.dj.orca-slicer;
in
{
  options.dj.orca-slicer = {
    enable = mkEnableOption "orca-slicer Desktop Environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      orca-slicer
    ];
  };
}
