{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        firefox
        discord
        fladder
        loupe
        mpv
        spotify
        zed-editor
      ];

      # chromium/electron apps (all three above) run native wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # niri defaults to the "default" cursor theme, which isn't installed;
      # without this, niri logs "error loading xcursor default@48: no default
      # icon" and the cursor is invisible, making mouse interaction impossible.
      # breeze_cursors is provided by kdePackages.breeze (installed for SDDM).
      environment.sessionVariables.XCURSOR_THEME = "breeze_cursors";
      environment.sessionVariables.XCURSOR_SIZE = "24";

      # Without a dedicated viewer, the browser's desktop entry is the only
      # thing claiming image/*, so images open in firefox. System-wide defaults
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
        inode/directory=thunar.desktop
      '';
    };
}
