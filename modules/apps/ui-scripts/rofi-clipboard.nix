{ pkgs }:
pkgs.writeShellScriptBin "rofi-clipboard" ''
  cliphist list |
    rofi -dmenu \
      -p 'Clipboard' \
      -config "$HOME/.config/rofi/regular.rasi" |
    cliphist decode |
    wl-copy
''
