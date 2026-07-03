{ lib, config, ... }:
{
  options.modules.recyclarr.enable = lib.mkEnableOption "Recyclarr TRaSH guides sync";

  config = lib.mkIf config.modules.recyclarr.enable {
    services.recyclarr = {
      enable = true;
      schedule = "daily";

      # API keys are read at runtime from root-owned files (0600),
      # created once during setup from Sonarr/Radarr -> Settings -> General
      configuration = {
        sonarr.main = {
          base_url = "http://localhost:8989";
          api_key._secret = "/fast/appdata/recyclarr/sonarr-api-key";
          include = [
            { template = "sonarr-quality-definition-series"; }
            { template = "sonarr-v4-quality-profile-web-1080p"; }
            { template = "sonarr-v4-custom-formats-web-1080p"; }
            { template = "sonarr-v4-quality-profile-anime"; }
            { template = "sonarr-v4-custom-formats-anime"; }
          ];

          # Require dual audio for anime (TRaSH: score 2000 + matching
          # minimum format score rejects anything without it)
          custom_formats = [
            {
              trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ]; # Anime Dual Audio
              assign_scores_to = [
                {
                  name = "Remux-1080p - Anime";
                  score = 2000;
                }
              ];
            }
          ];

          quality_profiles = [
            {
              name = "Remux-1080p - Anime";
              min_format_score = 2000;
            }
          ];
        };

        radarr.main = {
          base_url = "http://localhost:7878";
          api_key._secret = "/fast/appdata/recyclarr/radarr-api-key";
          include = [
            { template = "radarr-quality-definition-movie"; }
            { template = "radarr-quality-profile-hd-bluray-web"; }
            { template = "radarr-custom-formats-hd-bluray-web"; }
          ];
        };
      };
    };
  };
}
