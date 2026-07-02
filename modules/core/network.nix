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
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
  };

  services.automatic-timezoned.enable = true;
  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
