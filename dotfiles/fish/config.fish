if status is-interactive
    set -g fish_greeting

    # One-time Tide bootstrap; restyle any time with `tide configure`.
    # Tide stores its style in fish universal variables, which stay out of
    # this repo.
    if not set -q tide_character_color
        tide configure --auto --style=Lean --prompt_colors='True color' \
            --show_time=No --lean_prompt_height='Two lines' \
            --prompt_connection=Disconnected --prompt_spacing=Compact \
            --icons='Many icons' --transient=Yes 2>/dev/null
    end
end
