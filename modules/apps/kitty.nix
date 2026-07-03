{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
{
  options.modules.kitty.enable = lib.mkEnableOption "kitty Term";

  config = lib.mkIf config.modules.kitty.enable {
    environment.systemPackages = [ pkgs.kitty ];

    environment.etc."tmpfiles.d/home-${usr.login}-kitty.conf".text = ''
      R  /home/${usr.login}/.config/kitty - - - -
      L+ /home/${usr.login}/.config/kitty - ${usr.login} - - ${nixConfigPath}/dots/kitty
    '';
  };
}
