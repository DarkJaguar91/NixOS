{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dj.plasma;
in
{
  options.dj.plasma = {
    enable = mkEnableOption "Plasma Desktop Environment";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
