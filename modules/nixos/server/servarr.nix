# Sonarr, Radarr, Prowlarr, SABnzbd — the download/automation stack.
{
  flake.modules.nixos.server = {
    # cheetah3 (a sabctools/sabnzbd dep) ships as PyPI project "CT3", so its
    # .dist-info is ct3-*, but nixpkgs' pname is "cheetah3" — the metadata
    # check hook looks up importlib.metadata.version("cheetah3") and fails.
    # Was masked while python3.13 builds were cached; surfaced once
    # python3.14 became default and it had to build from source.
    nixpkgs.overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pyFinal: pyPrev: {
            cheetah3 = pyPrev.cheetah3.overrideAttrs {
              dontCheckPythonMetadata = true;
            };
          })
        ];
      })
    ];

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
        settings.misc = {
          host = "0.0.0.0"; # default 127.0.0.1 is LAN-inaccessible
          # unset, completed folders inherit the service umask (700) and
          # sonarr/radarr can't enter them to import
          permissions = "775";
        };
      };
    };

    # the sonarr module only creates dataDir when it's the default path
    # (radarr's module ships an equivalent rule; sonarr's doesn't)
    systemd.tmpfiles.rules = [ "d /fast/appdata/sonarr 0700 sonarr media -" ];
  };
}
