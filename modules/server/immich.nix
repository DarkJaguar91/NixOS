{ lib, config, ... }:
{
  options.modules.immich.enable = lib.mkEnableOption "Immich photo server";

  config = lib.mkIf config.modules.immich.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true; # 2283
      mediaLocation = "/media/photos";
      # accelerationDevices = [ "/dev/dri/renderD128" ];
    };

    # Postgres lives on the fast pool: the fast/immich-pg dataset is
    # mounted at /var/lib/postgresql (set via its zfs mountpoint property).
  };
}
