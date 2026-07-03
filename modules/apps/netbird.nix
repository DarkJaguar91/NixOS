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
    environment.systemPackages = [ pkgs.netbird-ui ];
  };
}
