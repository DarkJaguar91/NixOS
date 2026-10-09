# Gaming Mode in a window: the Deck UI (gamepadui + QAM, mangoapp
# performance overlay, Decky) inside a nested gamescope on the desktop,
# without leaving umbriel for the gamescope-wayland session.
#
# Jovian's start-gamescope-session can't be reused here: it assumes it owns
# the whole session (rewrites the GTK cursor theme, may delete games when
# the disk is nearly full, claims DRM outputs). This keeps only its
# Steam-facing environment.
#
# -steamos3 is what unlocks the QAM Performance tab (overlay level, TDP,
# limits). It also makes Steam drive steamos-manager for real: "Switch to
# Desktop" ends up in `steamosctl switch-to-desktop-mode`, and the power
# menu acts on the machine. To just close the window, quit Steam from the
# power menu ("Exit Steam") instead.
#
# Nested, gamescope runs one mangoapp per game window (virtual connectors),
# so none exists until a game has focus and the overlay level is non-off.
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      # GLFW prefers Wayland whenever it can reach a socket, and nested it
      # finds umbriel's. mangoapp then calls X11-only GLFW functions
      # ("X11: Platform not initialized") and crashes, leaving the QAM
      # performance overlay greyed out. Force it onto gamescope's Xwayland.
      mangoapp-x11 = pkgs.writeShellScriptBin "mangoapp" ''
        XDG_SESSION_TYPE=x11 exec ${pkgs.mangohud}/bin/mangoapp "$@"
      '';

      steam-gamescope = pkgs.writeShellScriptBin "steam-gamescope" ''
        export PATH=${mangoapp-x11}/bin:$PATH

        # Steam is single-instance; a running desktop client would just
        # get the new window forwarded to it, outside gamescope.
        if pgrep -x steam >/dev/null; then
            steam -shutdown >/dev/null 2>&1
            for _ in $(seq 60); do
                pgrep -x steam >/dev/null || break
                sleep 0.5
            done
        fi

        # Match the output's current mode (first enabled one), falling back
        # to the Z13 panel.
        mode=$(umbriel outputs 2>/dev/null | grep -m1 'current' | grep -oE '[0-9]+x[0-9]+ @ [0-9]+')
        width=''${mode%%x*}; rest=''${mode#*x}
        height=''${rest%% *}; refresh=''${mode##* }
        : "''${width:=2560}" "''${height:=1600}" "''${refresh:=180}"

        tmpdir=$(mktemp -d -p "$XDG_RUNTIME_DIR" steam-gamescope.XXXXXX)
        trap 'rm -rf "$tmpdir"' EXIT

        # Steam drives mangoapp itself (QAM performance levels); start hidden
        export STEAM_USE_MANGOAPP=1
        export STEAM_MANGOAPP_PRESETS_SUPPORTED=1
        export STEAM_MANGOAPP_HORIZONTAL_SUPPORTED=1
        export STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND=1
        export MANGOHUD_CONFIGFILE=$tmpdir/mangohud.config
        echo no_display > "$MANGOHUD_CONFIGFILE"

        export STEAM_GAMESCOPE_NIS_SUPPORTED=1
        export STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT=1
        export STEAM_GAMESCOPE_DYNAMIC_FPSLIMITER=1
        export GAMESCOPE_LIMITER_FILE=$tmpdir/limiter
        touch "$GAMESCOPE_LIMITER_FILE"
        export STEAM_MULTIPLE_XWAYLANDS=1
        export STEAM_DISABLE_AUDIO_DEVICE_SWITCHING=1
        export SRT_URLOPEN_PREFER_STEAM=1
        export vk_xwayland_wait_ready=false

        gamescope \
            -W "$width" -H "$height" -r "$refresh" -f \
            --xwayland-count 2 \
            -e --mangoapp \
            "$@" \
            -- steam -steamos3 -gamepadui
      '';
    in
    {
      environment.systemPackages = [
        steam-gamescope
        (pkgs.makeDesktopItem {
          name = "steam-gamescope";
          desktopName = "Steam Gaming Mode";
          comment = "Steam Deck UI in a nested gamescope window";
          exec = "steam-gamescope";
          icon = "steam";
          categories = [ "Game" ];
        })
      ];
    };
}
