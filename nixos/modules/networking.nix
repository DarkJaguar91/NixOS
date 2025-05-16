{ host, options, ... }: {
  networking = {
   hostName = "${host}";
   networkmanager.enable = true;
   timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };

  # Set your time zone.
  services.automatic-timezoned.enable = true; #based on IP location
}
