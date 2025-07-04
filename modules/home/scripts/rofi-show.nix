{pkgs}:
pkgs.writeShellScriptBin "rofi-show" ''
  if pidof rofi > /dev/null; then
    pkill rofi
  else
    rofi -show drun
  fi
''
