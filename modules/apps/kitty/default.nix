{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
with lib;
let
  cfg = config.dj.kitty;
in
{
  options.dj.kitty = {
    enable = mkEnableOption "kitty Term";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kitty
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-kitty.conf".text = ''
      L+    /home/${usr.login}/.config/kitty                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/kitty
    '';
  };
}
