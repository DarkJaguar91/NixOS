# Homepage dashboard at http://192.168.68.254:8082.
{
  flake.modules.nixos.server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # hrefs are opened by the browser, so they need the LAN address
      # (DJServer's static bond0 IP), not 127.0.0.1; widget/siteMonitor URLs
      # are fetched server-side by homepage itself, so those stay on localhost
      lanHost = "192.168.68.254";

      zfsApiPort = 8091;

      # zpool health/usage as JSON for the customapi widget; homepage has no
      # native ZFS integration
      zpoolStatusApi = pkgs.writeText "zpool-status-api.py" ''
        import json
        import subprocess
        from http.server import BaseHTTPRequestHandler, HTTPServer


        class Handler(BaseHTTPRequestHandler):
            def do_GET(self):
                out = subprocess.run(
                    ["zpool", "list", "-H", "-o", "name,health,capacity"],
                    capture_output=True, text=True, timeout=10,
                )
                pools = {}
                for line in out.stdout.splitlines():
                    name, health, capacity = line.split("\t")
                    pools[name] = {"health": health, "capacity": capacity}
                body = json.dumps(pools).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def log_message(self, *args):
                pass


        HTTPServer(("127.0.0.1", ${toString zfsApiPort}), Handler).serve_forever()
      '';

      # The live-status widgets need each app's API key. The keys already exist
      # in the apps' state dirs, so scrape them at startup instead of keeping a
      # secrets file by hand (rotating a key just needs a homepage restart).
      # Missing files produce empty vars — the affected widget errors, the rest
      # of the dashboard still works.
      #
      # Two keys need a one-time manual step:
      #  - Jellyfin: create a key under Dashboard > API Keys (any name); it then
      #    appears in the sqlite db scraped below
      #  - Immich: keys are stored hashed, so scraping is impossible — create one
      #    as an admin under Account Settings > API Keys and write it to
      #    /fast/appdata/homepage/immich-api-key
      collectSecrets = pkgs.writeShellScript "homepage-collect-secrets" ''
        set -u
        umask 077
        xml_key() { sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' "$1" 2>/dev/null; }
        {
          printf 'HOMEPAGE_VAR_SONARR_KEY=%s\n' "$(xml_key /fast/appdata/sonarr/config.xml)"
          printf 'HOMEPAGE_VAR_RADARR_KEY=%s\n' "$(xml_key /fast/appdata/radarr/config.xml)"
          printf 'HOMEPAGE_VAR_PROWLARR_KEY=%s\n' "$(xml_key /var/lib/prowlarr/config.xml)"
          printf 'HOMEPAGE_VAR_SABNZBD_KEY=%s\n' \
            "$(sed -n 's/^api_key *= *//p' /var/lib/sabnzbd/sabnzbd.ini 2>/dev/null | head -n1)"
          printf 'HOMEPAGE_VAR_JELLYFIN_KEY=%s\n' \
            "$(sqlite3 -readonly /fast/appdata/jellyfin/data/jellyfin.db \
                 'SELECT AccessToken FROM ApiKeys LIMIT 1' 2>/dev/null)"
          printf 'HOMEPAGE_VAR_PLEX_KEY=%s\n' \
            "$(sed -n 's/.*PlexOnlineToken="\([^"]*\)".*/\1/p' \
                 '/fast/appdata/plex/Plex Media Server/Preferences.xml' 2>/dev/null)"
          printf 'HOMEPAGE_VAR_SEERR_KEY=%s\n' \
            "$(jq -r '.main.apiKey // empty' /var/lib/seerr/settings.json 2>/dev/null)"
          printf 'HOMEPAGE_VAR_IMMICH_KEY=%s\n' \
            "$(cat /fast/appdata/homepage/immich-api-key 2>/dev/null)"
        } > /run/homepage-dashboard.env
      '';

      zfsMappings = lib.concatMap (pool: [
        {
          field.${pool} = "health";
          label = pool;
        }
        {
          field.${pool} = "capacity";
          label = "${pool} used";
        }
      ]) config.boot.zfs.extraPools;
    in
    {
      services.homepage-dashboard = {
        enable = true;
        openFirewall = true; # 8082
        # disables host-header validation, which buys nothing on a service
        # that's only reachable over LAN/Netbird
        allowedHosts = "*";
        environmentFiles = [ "/run/homepage-dashboard.env" ];

        settings = {
          title = "DJServer";
          theme = "dark";
          color = "slate";
          headerStyle = "clean";
          statusStyle = "dot";
          hideVersion = true;
          # list form keeps this order; an attrset would be alphabetised
          layout = [
            {
              Media = {
                style = "row";
                columns = 4;
              };
            }
            {
              Downloads = {
                style = "row";
                columns = 4;
              };
            }
            {
              AI = {
                style = "row";
                columns = 2;
              };
            }
            {
              System = {
                style = "row";
                columns = 2;
              };
            }
          ];
        };

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              cputemp = true;
              uptime = true;
              units = "metric";
            };
          }
          {
            datetime = {
              text_size = "xl";
              format = {
                dateStyle = "long";
                timeStyle = "short";
              };
            };
          }
        ];

        services = [
          {
            Media = [
              {
                Jellyfin = {
                  icon = "jellyfin";
                  href = "https://brandontalbot.com";
                  siteMonitor = "http://127.0.0.1:8096/health";
                  widget = {
                    type = "jellyfin";
                    url = "http://127.0.0.1:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                    enableBlocks = true; # library counts
                    enableNowPlaying = true;
                  };
                };
              }
              {
                Plex = {
                  icon = "plex";
                  href = "http://${lanHost}:32400/web";
                  # /identity answers without auth; the root path 401s
                  siteMonitor = "http://127.0.0.1:32400/identity";
                  widget = {
                    type = "plex";
                    url = "http://127.0.0.1:32400";
                    key = "{{HOMEPAGE_VAR_PLEX_KEY}}";
                  };
                };
              }
              {
                Seerr = {
                  icon = "jellyseerr";
                  href = "https://seerr.brandontalbot.com";
                  siteMonitor = "http://127.0.0.1:5055";
                  widget = {
                    type = "jellyseerr";
                    url = "http://127.0.0.1:5055";
                    key = "{{HOMEPAGE_VAR_SEERR_KEY}}";
                  };
                };
              }
              {
                Immich = {
                  icon = "immich";
                  href = "https://immich.brandontalbot.com";
                  siteMonitor = "http://127.0.0.1:2283";
                  widget = {
                    type = "immich";
                    url = "http://127.0.0.1:2283";
                    key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                    version = 2; # required for immich >= 1.118
                    fields = [
                      "photos"
                      "videos"
                      "storage"
                    ];
                  };
                };
              }
            ];
          }
          {
            Downloads = [
              {
                Sonarr = {
                  icon = "sonarr";
                  href = "http://${lanHost}:8989";
                  widget = {
                    type = "sonarr";
                    url = "http://127.0.0.1:8989";
                    key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                  };
                };
              }
              {
                Radarr = {
                  icon = "radarr";
                  href = "http://${lanHost}:7878";
                  widget = {
                    type = "radarr";
                    url = "http://127.0.0.1:7878";
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                  };
                };
              }
              {
                Prowlarr = {
                  icon = "prowlarr";
                  href = "http://${lanHost}:9696";
                  widget = {
                    type = "prowlarr";
                    url = "http://127.0.0.1:9696";
                    key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                  };
                };
              }
              {
                SABnzbd = {
                  icon = "sabnzbd";
                  href = "http://${lanHost}:8080";
                  widget = {
                    type = "sabnzbd";
                    url = "http://127.0.0.1:8080";
                    key = "{{HOMEPAGE_VAR_SABNZBD_KEY}}";
                  };
                };
              }
            ];
          }
          {
            AI = [
              {
                "Open WebUI" = {
                  icon = "open-webui";
                  href = "http://${lanHost}:8083";
                  siteMonitor = "http://127.0.0.1:8083";
                };
              }
              {
                Ollama = {
                  icon = "ollama";
                  # the root path just answers "Ollama is running"
                  siteMonitor = "http://127.0.0.1:11434";
                };
              }
            ];
          }
          {
            System = [
              {
                Netdata = {
                  icon = "netdata";
                  href = "http://${lanHost}:19999";
                  widget = {
                    type = "netdata";
                    url = "http://127.0.0.1:19999";
                  };
                };
              }
              {
                "ZFS Pools" = {
                  icon = "mdi-harddisk";
                  widget = {
                    type = "customapi";
                    url = "http://127.0.0.1:${toString zfsApiPort}";
                    refreshInterval = 60000;
                    mappings = zfsMappings;
                  };
                };
              }
            ];
          }
        ];
      };

      # holds the manually-created immich API key (see collectSecrets)
      systemd.tmpfiles.rules = [ "d /fast/appdata/homepage 0700 root root -" ];

      # runs as root because homepage's DynamicUser can't read the apps'
      # config files; re-runs on every homepage (re)start via RequiredBy
      systemd.services.homepage-dashboard-secrets = {
        description = "Collect app API keys for Homepage widgets";
        before = [ "homepage-dashboard.service" ];
        requiredBy = [ "homepage-dashboard.service" ];
        path = with pkgs; [
          jq
          sqlite
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = collectSecrets;
        };
      };

      # /dev/zfs is world-rw, so read-only zpool commands work unprivileged
      systemd.services.zpool-status-api = {
        description = "zpool health JSON for the Homepage dashboard";
        wantedBy = [ "multi-user.target" ];
        path = [ config.boot.zfs.package ];
        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${lib.getExe pkgs.python3} ${zpoolStatusApi}";
          Restart = "on-failure";
        };
      };
    };
}
