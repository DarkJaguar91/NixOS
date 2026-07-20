# Recyclarr TRaSH guides sync for Sonarr/Radarr quality profiles.
{
  flake.modules.nixos.server = {
    services.recyclarr = {
      enable = true;
      schedule = "daily";

      # API keys are read at runtime from root-owned files (0600),
      # created once during setup from Sonarr/Radarr -> Settings -> General
      #
      # Profiles are synced whole from TRaSH guides by trash_id (recyclarr
      # v8 scheme — the old include templates were removed upstream).
      # Reference: the config-templates repo's web-1080p, anime-remux-1080p
      # and hd-bluray-web templates.
      configuration = {
        # instance names must be unique across sonarr AND radarr —
        # duplicates make recyclarr skip the sync silently
        sonarr.sonarr-main = {
          base_url = "http://localhost:8989";
          api_key._secret = "/fast/appdata/recyclarr/sonarr-api-key";

          quality_definition.type = "series";

          quality_profiles = [
            {
              trash_id = "72dae194fc92bf828f32cde7744e51a1"; # WEB-1080p
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
              reset_unmatched_scores.enabled = true;
              # paired with the dual-audio score below: rejects releases
              # without dual audio
              min_format_score = 2000;
            }
          ];

          custom_formats = [
            {
              trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ]; # Anime Dual Audio
              assign_scores_to = [
                {
                  name = "[Anime] Remux-1080p";
                  score = 2000;
                }
              ];
            }
          ];

          # TRaSH recommended naming. The id-free "default" formats work for
          # both Plex and Jellyfin (the plex-*/jellyfin-* variants embed
          # provider ids in mutually incompatible syntax). The anime episode
          # format adds absolute numbering, audio languages, and release
          # group — applies to series whose type is set to Anime in Sonarr.
          media_naming = {
            series = "default";
            season = "default";
            episodes = {
              rename = true;
              standard = "default";
              anime = "default";
            };
          };
        };

        radarr.radarr-main = {
          base_url = "http://localhost:7878";
          api_key._secret = "/fast/appdata/recyclarr/radarr-api-key";

          quality_definition.type = "movie";

          quality_profiles = [
            {
              trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
              reset_unmatched_scores.enabled = true;
            }
          ];

          media_naming = {
            folder = "default";
            movie = {
              rename = true;
              standard = "standard";
            };
          };
        };
      };
    };
  };
}
