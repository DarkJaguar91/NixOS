{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.modules.netbird.enable = lib.mkEnableOption "Netbird VPN client";

  config = lib.mkIf config.modules.netbird.enable {
    services.netbird.enable = true;
    # tray UI only makes sense on graphical hosts; servers get the CLI alone
    environment.systemPackages = lib.optional config.services.xserver.enable pkgs.netbird-ui;
  };
}
