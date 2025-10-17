{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "wall-select" ''
  notify-send "lol wall-select"
''
