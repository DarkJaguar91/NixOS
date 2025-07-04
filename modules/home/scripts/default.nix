{
  pkgs,
  lib,
  ...
}: let
  scripts = [
    ./asus-profile-switch.nix
    ./take-screenshot.nix
    ./task-waybar.nix
    ./rofi-show.nix
    ./wall-select.nix
  ];
in {
  home.packages = lib.forEach scripts (script: (import script {inherit pkgs;}));
}
