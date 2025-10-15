{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.dj.qmk;
in
{
  options.dj.qmk = {
    enable = mkEnableOption "QMK Setup and software";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qmk
      via
      vial
    ];

    hardware.keyboard.qmk.enable = true;
    services.udev.packages = with pkgs; [
      via
      vial
    ];
  };
}
