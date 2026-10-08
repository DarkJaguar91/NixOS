{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        chromium # WebUSB (e.g. openpuck configurator), which firefox lacks
        discord
        fladder
        file-roller
        loupe
        spotify
        zed-editor
      ];

      # GTK3, so noctalia's gtk3 template + adw-gtk3 theme it like everything
      # else; gvfs/udisks2 for mounts and mtp/smb live in automount.nix
      programs.thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-archive-plugin # right-click extract/compress (needs file-roller)
          thunar-volman
        ];
      };
      programs.xfconf.enable = true; # thunar saves its preferences through xfconf
      services.tumbler.enable = true; # thumbnails

      # chromium/electron apps (discord, spotify, ...) run native wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Compositors fall back to the "default" cursor theme, which isn't
      # installed; without this the cursor can end up invisible ("error
      # loading xcursor default@48: no default icon").
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
        inode/directory=yazi-kitty.desktop;thunar.desktop
      '';
    };
}
