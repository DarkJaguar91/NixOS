{
  pkgs,
  host,
  options,
  ...
}:
{
  networking = {
    hostName = "${host}";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    nameservers = [ "192.168.68.246" ];
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "192.168.68.246" ];
  };

  services.automatic-timezoned.enable = true;
  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
