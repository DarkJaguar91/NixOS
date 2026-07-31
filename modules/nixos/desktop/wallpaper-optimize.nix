# wallpaper-optimize: re-encodes ~/Videos/Wallpapers clips to the display's
# native resolution @ <=30fps h264 (no audio), so mpvpaper does zero scaling
# and minimal VCN decode work. The target resolution is detected from niri
# (or the first connected DRM connector), so it works on any host. Files
# that already match are skipped, so it's safe to re-run after dropping in
# new wallpapers; originals are preserved in <dir>/originals/. ffmpeg for
# everyday use ships in base/cli-tools.nix.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      wallpaperOptimize = pkgs.writeShellApplication {
        name = "wallpaper-optimize";
        runtimeInputs = [ pkgs.ffmpeg ];
        text = ''
          DIR=''${1:-$HOME/Videos/Wallpapers}
          TFPS=30   # frame-rate cap

          # Target = the display's current mode: ask niri first (works for
          # any monitor), then the first connected DRM connector's preferred
          # mode, then fall back to the AsusZ13 panel.
          detect_res() {
            local mode
            mode=$(niri msg outputs 2>/dev/null | grep -m1 'Current mode:' | grep -oE '[0-9]+x[0-9]+' || true)
            if [ -n "$mode" ]; then
              echo "$mode"
              return
            fi
            for status in /sys/class/drm/card*-*/status; do
              [ "$(cat "$status" 2>/dev/null)" = connected ] || continue
              mode=$(head -n1 "''${status%/status}/modes" 2>/dev/null)
              if [ -n "$mode" ]; then
                echo "$mode"
                return
              fi
            done
            echo "2560x1600"
          }

          RES=$(detect_res)
          TW=''${RES%x*}
          TH=''${RES#*x}
          echo "wallpaper-optimize: target ''${TW}x''${TH} @ <=''${TFPS}fps ($DIR)"

          shopt -s nullglob
          videos=("$DIR"/*.mp4 "$DIR"/*.mkv "$DIR"/*.webm "$DIR"/*.mov)

          if [ ''${#videos[@]} -eq 0 ]; then
            echo "wallpaper-optimize: no videos found in $DIR"
            exit 0
          fi

          for f in "''${videos[@]}"; do
            base=$(basename "$f")
            info=$(ffprobe -v error -select_streams v:0 \
              -show_entries stream=codec_name,width,height,r_frame_rate \
              -of csv=p=0 "$f")
            if [ -z "$info" ]; then
              echo "skip  $base (no video stream)"
              continue
            fi
            IFS=, read -r codec w h rate <<<"$info"
            fps=$(awk -F/ '{ if ($2+0 == 0) print 0; else printf "%.2f", $1/$2 }' <<<"$rate")
            has_audio=$(ffprobe -v error -select_streams a:0 \
              -show_entries stream=codec_name -of csv=p=0 "$f" | head -n1)

            resize=no
            capfps=no
            transcode=no
            strip=no
            reasons=""

            if [ "$w" != "$TW" ] || [ "$h" != "$TH" ]; then
              resize=yes
              reasons="$reasons ''${w}x''${h}->''${TW}x''${TH}"
            fi
            if awk -v f="$fps" -v t="$TFPS" 'BEGIN { exit !(f > t) }'; then
              capfps=yes
              reasons="$reasons ''${fps}fps->''${TFPS}fps"
            fi
            case "$codec" in
              h264 | hevc | av1) ;;
              *)
                transcode=yes
                reasons="$reasons $codec->h264"
                ;;
            esac
            if [ -n "$has_audio" ]; then
              strip=yes
              reasons="$reasons strip-audio"
            fi

            if [ "$resize$capfps$transcode$strip" = "nononono" ]; then
              echo "skip  $base (''${w}x''${h} @ ''${fps}fps, $codec)"
              continue
            fi

            echo "encode $base:$reasons"
            filters=()
            [ "$capfps" = yes ] && filters+=("fps=$TFPS")
            [ "$resize" = yes ] && filters+=("scale=$TW:$TH:force_original_aspect_ratio=increase:flags=lanczos" "crop=$TW:$TH")
            vf=$(IFS=,; echo "''${filters[*]}")

            out="''${f%.*}.mp4"
            tmp="$DIR/.tmp-''${base%.*}.mp4"
            args=(-c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p -an -movflags +faststart)
            [ -n "$vf" ] && args=(-vf "$vf" "''${args[@]}")

            if ! ffmpeg -y -v error -i "$f" "''${args[@]}" "$tmp"; then
              echo "FAIL  $base (encode error), keeping original"
              rm -f "$tmp"
              continue
            fi

            exp_w=$w
            exp_h=$h
            [ "$resize" = yes ] && { exp_w=$TW; exp_h=$TH; }
            dims=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$tmp")
            if [ "$dims" != "$exp_w,$exp_h" ]; then
              echo "FAIL  $base (got ''${dims:-nothing}, expected $exp_w,$exp_h), keeping original"
              rm -f "$tmp"
              continue
            fi

            mkdir -p "$DIR/originals"
            mv "$f" "$DIR/originals/$base"
            mv "$tmp" "$out"
            old_size=$(du -h "$DIR/originals/$base" | cut -f1)
            new_size=$(du -h "$out" | cut -f1)
            echo "done  $base ($old_size -> $new_size)"
          done
        '';
      };
    in
    {
      environment.systemPackages = [ wallpaperOptimize ];
    };
}
