{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.media.enable = lib.mkEnableOption "media (Spotify)";

  config = lib.mkIf config.modules.media.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];
  };
}
