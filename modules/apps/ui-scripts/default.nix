{
  pkgs,
  config,
  lib,
  usr,
  ...
}:
with lib;
let
  cfg = config.dj.ui-scripts;
  scripts = [
    ./brightness.nix
    ./volume.nix
    ./wall-select.nix
  ];
in
{
  options.dj.ui-scripts = {
    enable = mkEnableOption "Common UI Scripts";
  };

  config = mkIf cfg.enable {
    environment.etc."tmpfiles.d/home-${usr.login}-ui-scripts.conf".text = ''
      L+    /home/${usr.login}/.config/scripts                   -    ${usr.login}    -     -           ${builtins.toString ./.}/scripts
    '';

    environment.systemPackages = forEach scripts (script: (import script { inherit pkgs; }));
  };
}
