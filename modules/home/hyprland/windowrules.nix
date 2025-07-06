_: {
  wayland.windowManager.hyprland = {
    settings = {
      windowrulev2 = [
        ##############
        ## Tags ######
        ##############

        # Browser
        "tag +browser, class:^([Bb]rave-browser(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
        "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
        "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"

        # File Manager
        "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"

        # Terminals
        "tag +terminal, class:^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$"

        # Projects/Coding
        "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
        "tag +projects, class:^(VSCode|code-url-handler)$"
        "tag +projects, class:^(jetbrains-.+)$"

        # Media players
        "tag +media, class:^([sS]potify)$"

        # Instance Messangers
        "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
        "tag +im, class:^([Ff]erdium)$"
        "tag +im, class:^([Ww]hatsapp-for-linux)$"
        "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
        "tag +im, class:^(teams-for-linux)$"

        # Games & Stores
        "tag +games, class:^(gamescope)$"
        "tag +games, class:^steam_app_.*$"
        "tag +gamestore, class:^([Ss]team)$"
        "tag +gamestore, title:^([Ll]utris)$"
        "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"

        # Settings windows
        "tag +settings, title:^(ROG Control)$"
        "tag +settings, class:^(wihotspot(-gui)?)$"
        "tag +settings, class:^([Bb]aobab|org.gnome.[Bb]aobab)$"
        "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, title:(Kvantum Manager)"
        "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, class:^(qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
        "tag +settings, class:^([Rr]ofi)$"
        "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
        "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
        "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "tag +settings, class:^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
        "tag +settings, class:(xdg-desktop-portal-gtk)"
        "tag +settings, class:(.blueman-manager-wrapped)"
        "tag +settings, class:(nwg-displays)"

        # Viewer tools
        "tag +viewer, class:^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$"
        "tag +viewer, class:^(evince)$"
        "tag +viewer, class:^(eog|org.gnome.Loupe)$"

        ##############
        ## Positions #
        ##############
        "move 72% 7%,title:^(Picture-in-Picture)$"
        "center, class:^([Ff]erdium)$"
        "float, class:^([Ww]aypaper)$"
        "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
        "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "center, title:^(Authentication Required)$"
        "center, title:^(ROG Control)$"
        "center, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$"
        "move 72% 7%,title:^(Picture-in-Picture)$"

        #################
        ## Stop Locking #
        #################
        "idleinhibit fullscreen, class:^(*)$"
        "idleinhibit fullscreen, title:^(*)$"
        "idleinhibit fullscreen, fullscreen:1"

        ########################
        ## Workspace Positions #
        ########################
        "workspace 1, tag:browser*"
        "workspace 2, tag:im*"
        "workspace 2, tag:media*"
        "workspace 3, tag:projects*"
        "workspace 4, tag:gamestore*"
        "workspace 5, tag:games*"

        ############
        # Floating #
        ############
        "float, tag:settings*"
        "float, class:^([Ff]erdium)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(mpv|com.github.rafostar.Clapper)$"
        "float, title:^(Authentication Required)$"
        "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
        "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
        "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
        "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
        "float, initialTitle:(Add Folder to Workspace)"
        "float, initialTitle:(Open Files)"
        "float, initialTitle:(wants to save)"

        ############
        # Resize   #
        ############
        "size 70% 60%, initialTitle:(Open Files)"
        "size 70% 60%, initialTitle:(Add Folder to Workspace)"
        "size 70% 70%, tag:settings*"
        "size 60% 70%, class:^([Ff]erdium)$"

        ############
        # Opacity  #
        ############
        "opacity 1.0 1.0, tag:browser*"
        "opacity 0.9 0.8, tag:projects*"
        "opacity 0.94 0.86, tag:im*"
        "opacity 0.9 0.8, tag:file-manager*"
        "opacity 0.8 0.7, tag:terminal*"
        "opacity 0.8 0.7, tag:settings*"
        "opacity 0.8 0.7, class:^(gedit|org.gnome.TextEditor|mousepad)$"
        "opacity 0.9 0.8, class:^(seahorse)$ # gnome-keyring gui"
        "opacity 0.95 0.75, title:^(Picture-in-Picture)$"

        ############
        # Pinning  #
        ############
        "pin, title:^(Picture-in-Picture)$"

        ############
        # Special  #
        ############
        "keepaspectratio, title:^(Picture-in-Picture)$"
        "noblur, tag:games*"
        "fullscreen, tag:games*"
      ];

      env = [
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,nvim"
      ];
    };
  };
}
