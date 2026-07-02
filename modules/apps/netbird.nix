{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.netbird;
in
{
  options.modules.netbird = {
    enable = mkEnableOption "Netbird VPN client";
  };

  config = mkIf cfg.enable {
    services.netbird.enable = true;
    environment.systemPackages = with pkgs; [ netbird-ui ];
  };
}
