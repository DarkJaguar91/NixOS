{ pkgs, ... }:
pkgs.writeShellScriptBin "wall-select" ''
  # check if rofi is already running
  if pidof rofi > /dev/null; then
    pkill rofi
  fi

  WPATH=~/Pictures/Wallpapers

  # THEME="~/.config/rofi/config-wallpaper.rasi"
  THEME="fullscreen-preview.rasi"

  # Get user selection via wofi from emoji file.
  chosen=$(find $WPATH -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" | grep -Po "[^/]+\$" | while read f; do echo -en "$f\0icon\x1f$WPATH/$f\n"; done | ${pkgs.rofi-wayland}/bin/rofi -i -dmenu -config $THEME)

  # Exit if none chosen.
  [ -z "$chosen" ] && exit

  swww img "$WPATH/$chosen"
''
