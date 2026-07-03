{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.modules.media.enable = lib.mkEnableOption "Media Apps (Spotiyfy, Discord, ...)";

  config = lib.mkIf config.modules.media.enable {
    environment.systemPackages = with pkgs; [
      brave
      spotify
      discord
      # QtWebEngine 6.11's GBM zero-copy path breaks video playback on native
      # Wayland (black video, "non-existent mailbox" GPU errors)
      (symlinkJoin {
        name = "jellyfin-desktop";
        paths = [ jellyfin-desktop ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/jellyfin-desktop \
            --set QTWEBENGINE_FORCE_USE_GBM 0
        '';
      })
    ];
  };
}
