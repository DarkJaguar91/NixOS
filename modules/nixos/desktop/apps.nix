{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        brave
        discord
        loupe
        mpv
        spotify
      ];

      # chromium/electron apps (all three above) run native wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Without a dedicated viewer, the browser's desktop entry is the only
      # thing claiming image/*, so images open in brave. System-wide defaults
      # here; ~/.config/mimeapps.list still wins for anything it names.
      environment.etc."xdg/mimeapps.list".text = ''
        [Default Applications]
        image/png=org.gnome.Loupe.desktop
        image/jpeg=org.gnome.Loupe.desktop
        image/gif=org.gnome.Loupe.desktop
        image/webp=org.gnome.Loupe.desktop
        image/bmp=org.gnome.Loupe.desktop
        image/tiff=org.gnome.Loupe.desktop
        image/svg+xml=org.gnome.Loupe.desktop
        image/avif=org.gnome.Loupe.desktop
        image/heif=org.gnome.Loupe.desktop
      '';
    };
}
