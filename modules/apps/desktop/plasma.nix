{ lib, config, ... }: {
  options.modules.desktop.plasma.enable = lib.mkEnableOption "KDE Plasma";

  config = lib.mkIf config.modules.desktop.plasma.enable {
    services.desktopManager.plasma6.enable = true;
  };
}
