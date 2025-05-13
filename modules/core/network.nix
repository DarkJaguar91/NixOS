{
  pkgs,
  host,
  options,
  ...
}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
  };

  environment.systemPackages = with pkgs; [networkmanagerapplet];
}
