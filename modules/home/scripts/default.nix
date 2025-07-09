{
  pkgs,
  lib,
  ...
}: let
  scripts = [
    ./asus-profile-switch.nix
    ./record-screen-area.nix
    ./rofi-show.nix
    ./take-screenshot.nix
    ./task-waybar.nix
    ./wall-select.nix
  ];
in {
  home.packages = lib.forEach scripts (script: (import script {inherit pkgs;}));
}
