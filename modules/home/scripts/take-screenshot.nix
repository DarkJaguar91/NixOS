{ pkgs }:

pkgs.writeShellScriptBin "take-screenshot" ''
  grim -g "$(slurp)" - | swappy -f -
''
