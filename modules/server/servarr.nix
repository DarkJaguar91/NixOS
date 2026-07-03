{ lib, config, ... }:
{
  options.modules.servarr.enable = lib.mkEnableOption "Sonarr, Radarr, Prowlarr, SABnzbd";

  config = lib.mkIf config.modules.servarr.enable {
    users.groups.media = { };

    services.sonarr = {
      enable = true;
      group = "media";
      openFirewall = true; # 8989
      dataDir = "/fast/appdata/sonarr";
    };

    systemd.tmpfiles.rules = [ "d /fast/appdata/sonarr 0700 sonarr media -" ];

    services.radarr = {
      enable = true;
      group = "media";
      openFirewall = true; # 7878
      dataDir = "/fast/appdata/radarr";
    };

    services.prowlarr = {
      enable = true;
      openFirewall = true; # 9696
    };

    services.sabnzbd = {
      enable = true;
      group = "media";
      openFirewall = true; # 8080
      allowConfigWrite = true; # let the web UI save settings
      settings.misc.host = "0.0.0.0"; # default 127.0.0.1 is LAN-inaccessible
    };
  };
}
