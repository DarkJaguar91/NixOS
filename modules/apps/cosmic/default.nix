{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dj.cosmic;
in
{
  options.dj.cosmic = {
    enable = mkEnableOption "Cosmic Desktop Environment";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
  };
}
