if status is-interactive
    # tide prompt is installed via nix — initialise it on first run
    if not functions -q _tide_init
        tide configure --auto --style=Lean --prompt_colors='True color' \
            --show_time=No --lean_prompt_height='Two lines' \
            --prompt_connection=Disconnected --prompt_spacing=Compact \
            --icons='Many icons' --transient=Yes 2>/dev/null
    end
end
