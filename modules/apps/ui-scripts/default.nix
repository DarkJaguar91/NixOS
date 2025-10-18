{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dj.ui-scripts;
  scripts = [
    ./brightness.nix
    ./list-niri-window.nix
    ./rofi-bluetooth.nix
    ./rofi-clipboard.nix
    ./rofi-power.nix
    ./rofi-wall.nix
    ./rofi-wifi.nix
    ./set-wall.nix
    ./take-screenshot.nix
    ./volume.nix
    ./wall-select.nix
  ];
in
{
  options.dj.ui-scripts = {
    enable = mkEnableOption "Common UI Scripts";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = forEach scripts (script: (import script { inherit pkgs; }));
  };
}
