{
  config,
  lib,
  usr,
  nixConfigPath,
  ...
}:
with lib;
let
  cfg = config.dj.wallpapers;
in
{
  options.dj.wallpapers = {
    enable = mkEnableOption "Setup a wallpaper directory";
  };

  config = mkIf cfg.enable {
    environment.etc."tmpfiles.d/home-${usr.login}-niri.conf".text = ''
      L+    /home/${usr.login}/Wallpapers                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/Wallpapers
    '';
  };
}
