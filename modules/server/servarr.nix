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

    services.radarr = {
      enable = true;
      group = "media";
      openFirewall = true; # 7878
      dataDir = "/fast/appdata/radarr";
    };

    services.prowlarr = {
      enable = true;
      openFirewall = true; # 9696
      dataDir = "/fast/appdata/prowlarr";
    };

    services.sabnzbd = {
      enable = true;
      group = "media";
      openFirewall = true; # 8080
      stateDir = "/fast/appdata/sabnzbd";
    };
  };
}
