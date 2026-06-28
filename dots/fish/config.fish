if status is-interactive
    if not set -q tide_character_color
        tide configure --auto --style=Lean --prompt_colors='True color' \
            --show_time=No --lean_prompt_height='Two lines' \
            --prompt_connection=Disconnected --prompt_spacing=Compact \
            --icons='Many icons' --transient=Yes 2>/dev/null
    end
end
