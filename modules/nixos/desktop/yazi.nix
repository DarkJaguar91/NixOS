# Yazi as the file manager in the terminal and as the system file picker:
# xdg-desktop-portal-termfilechooser answers the portal's FileChooser
# requests (browser downloads, "upload file" dialogs, ...) by opening yazi
# in a kitty window instead of a GTK dialog.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      termfilechooser = pkgs.xdg-desktop-portal-termfilechooser;
    in
    {
      programs.yazi.enable = true;

      # Default handler for folders (mimeapps.list in apps.nix). yazi's own
      # yazi.desktop is Terminal=true, which leaves picking a terminal to
      # whatever opens it; this one launches kitty explicitly.
      environment.systemPackages = [
        (pkgs.makeDesktopItem {
          name = "yazi-kitty";
          desktopName = "Yazi";
          icon = "yazi";
          exec = "kitty --class yazi yazi %f";
          mimeTypes = [ "inode/directory" ];
          noDisplay = true;
        })
      ];

      xdg.portal = {
        extraPortals = [ termfilechooser ];
        # merges with umbriel's `default = [ "umbriel" "gtk" ]`
        config.umbriel."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };

      # --class sets kitty's wayland app_id, which the umbriel window rule
      # matches to float the picker
      environment.etc."xdg/xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        default_dir=$HOME
        create_help_file=0
        env=TERMCMD=kitty --class termfilechooser --title 'Select file'
        open_mode=suggested
        save_mode=last
      '';

      # Firefox only goes through the portal for file dialogs when asked to
      programs.firefox = {
        enable = true;
        preferences."widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      # GTK apps (loupe, ...) otherwise open their own dialog outside a sandbox
      environment.sessionVariables.GDK_DEBUG = "portals";
    };
}
