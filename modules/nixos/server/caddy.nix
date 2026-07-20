# Caddy reverse proxy with Let's Encrypt.
{ config, ... }:
{
  flake.modules.nixos.server = {
    # Only these vhosts are reachable from outside; everything else stays
    # LAN/Netbird-only. Requires 80+443 forwarded to this host on the router
    # (80 is needed for the ACME HTTP-01 challenge).
    services.caddy = {
      enable = true;
      email = config.flake.meta.owner.email; # Let's Encrypt expiry notices
      virtualHosts = {
        "brandontalbot.com".extraConfig = ''
          reverse_proxy 127.0.0.1:8096
        '';
        "seerr.brandontalbot.com".extraConfig = ''
          reverse_proxy 127.0.0.1:5055
        '';
        "immich.brandontalbot.com".extraConfig = ''
          reverse_proxy 127.0.0.1:2283
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
