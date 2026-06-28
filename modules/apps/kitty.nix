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
  cfg = config.modules.kitty;
in
{
  options.modules.kitty = {
    enable = mkEnableOption "kitty Term";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kitty
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-kitty.conf".text = ''
      L+ /home/${usr.login}/.config/kitty - ${usr.login} - - ${nixConfigPath}/dots/kitty
    '';
  };
}
