{ lib, config, ... }:
{
  options.modules.servarr.enable = lib.mkEnableOption "Sonarr, Radarr, Prowlarr, SABnzbd";

  config = lib.mkIf config.modules.servarr.enable {
    users.groups.media = { };

    services = {
      sonarr = {
        enable = true;
        group = "media";
        openFirewall = true; # 8989
        dataDir = "/fast/appdata/sonarr";
      };

      radarr = {
        enable = true;
        group = "media";
        openFirewall = true; # 7878
        dataDir = "/fast/appdata/radarr";
      };

      # prowlarr runs as a DynamicUser; a custom dataDir gets bind-mounted
      # root-owned over /var/lib/private/prowlarr and systemd won't fix
      # ownership of mount points, so the service can't write. State is
      # tiny (indexer defs) — keep it on the root disk.
      prowlarr = {
        enable = true;
        openFirewall = true; # 9696
      };

      sabnzbd = {
        enable = true;
        group = "media";
        openFirewall = true; # 8080
        # stateDir is a name under /var/lib, not an absolute path — state
        # (config, queue metadata) stays on the root disk; downloads get
        # pointed at the media pool in the web UI
        allowConfigWrite = true; # let the web UI save settings
        settings.misc.host = "0.0.0.0"; # default 127.0.0.1 is LAN-inaccessible
      };
    };

    # the sonarr module only creates dataDir when it's the default path
    # (radarr's module ships an equivalent rule; sonarr's doesn't)
    systemd.tmpfiles.rules = [ "d /fast/appdata/sonarr 0700 sonarr media -" ];
  };
}
