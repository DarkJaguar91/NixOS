if status is-interactive
    set -g fish_greeting

    # zoxide: `z <dir>` jumps to frecent dirs, `zi` picks interactively (fzf).
    zoxide init fish | source

    # fzf keybindings: Ctrl+R history, Ctrl+T insert file, Alt+C cd into dir.
    fzf --fish | source
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || eza --tree --color=always --level=2 {}'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always --level=2 {}'"

    # bat for man pages and as a drop-in cat.
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    alias cat "bat --paging=never"

    # eza as ls.
    alias ls "eza --icons --group-directories-first"
    alias ll "eza -l --icons --group-directories-first --git --header"
    alias la "eza -la --icons --group-directories-first --git --header"
    alias lt "eza --tree --icons --group-directories-first --level=2"

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
