{ pkgs }:
pkgs.writeShellScriptBin "rofi-show" ''
  # check if rofi is already running
  if pidof rofi > /dev/null; then
    pkill rofi
  fi
  rofi -show drun
''
