{ lib, config, ... }:
{
  options.modules.dns.enable = lib.mkEnableOption "AdGuard Home DNS";

  config = lib.mkIf config.modules.dns.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true; # web UI on 3000
      settings.dns.upstream_dns = [
        "9.9.9.9"
        "1.1.1.1"
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    # core/network.nix enables systemd-resolved, whose stub listener
    # would otherwise fight AdGuard for port 53
    services.resolved.settings.Resolve.DNSStubListener = "no";
  };
}
