{ lib, config, ... }:
{
  options.modules.streaming = {
    plex.enable = lib.mkEnableOption "Plex Media Server";
    jellyfin.enable = lib.mkEnableOption "Jellyfin";
  };

  config = lib.mkMerge [
    (lib.mkIf
      (config.modules.streaming.plex.enable || config.modules.streaming.jellyfin.enable)
      {
        users.groups.media = { };
        hardware.graphics.enable = true; # VAAPI transcoding
      }
    )

    (lib.mkIf config.modules.streaming.plex.enable {
      services.plex = {
        enable = true;
        group = "media";
        openFirewall = true; # 32400
        dataDir = "/fast/appdata/plex";
      };
    })

    (lib.mkIf config.modules.streaming.jellyfin.enable {
      services.jellyfin = {
        enable = true;
        group = "media";
        openFirewall = true; # 8096
        dataDir = "/fast/appdata/jellyfin";
      };
    })
  ];
}
