{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dj.gnome;
in
{
  options.dj.gnome = {
    enable = mkEnableOption "Gnome Desktop Environment";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    programs.seahorse.enable = true;
  };
}
