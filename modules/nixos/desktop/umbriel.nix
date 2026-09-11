{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    let
      toggle-screenrecord = pkgs.writeShellScriptBin "toggle-screenrecord" ''
        PIDFILE="/tmp/umbriel-screenrecord.pid"
        MODE="''${1:-fullscreen}"
        VIDEOS_DIR="$HOME/Videos"
        mkdir -p "$VIDEOS_DIR"

        stop_recording() {
            if [[ -f "$PIDFILE" ]]; then
                local pid
                pid="$(cat "$PIDFILE")"
                rm -f "$PIDFILE"
                if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                    kill -INT "$pid" 2>/dev/null || true
                    wait "$pid" 2>/dev/null || true
                    return 0
                fi
            fi
            pkill -INT -x wl-screenrec 2>/dev/null || true
        }

        start_recording() {
            local mode="$1"
            local timestamp output geometry

            timestamp="$(date +%Y%m%d_%H%M%S)"
            output="''${VIDEOS_DIR}/recording_''${mode}_''${timestamp}.mp4"

            if [[ "$mode" == "region" ]]; then
                if ! geometry="$(slurp 2>/dev/null)" || [[ -z "$geometry" ]]; then
                    echo "Area selection cancelled" >&2
                    exit 0
                fi
                wl-screenrec --geometry "$geometry" -f "$output" &
            else
                wl-screenrec -f "$output" &
            fi

            local pid=$!
            echo "$pid" > "$PIDFILE"
        }

        if [[ -f "$PIDFILE" ]]; then
            pid="$(cat "$PIDFILE")"
            if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                stop_recording
                exit 0
            else
                rm -f "$PIDFILE"
            fi
        fi

        if pgrep -x wl-screenrec >/dev/null 2>&1; then
            stop_recording
            exit 0
        fi

        start_recording "$MODE"
      '';
    in
    {
      imports = [
        inputs.umbriel.nixosModules.default
      ];

      # Enable Umbriel Wayland compositor
      programs.umbriel = {
        enable = true;
      };

      dots.directories.".config/umbriel" = "umbriel";

      environment.systemPackages = with pkgs; [
        wl-screenrec
        toggle-screenrecord
      ];
    };
}
