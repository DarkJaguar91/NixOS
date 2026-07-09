# claude-code against DJServer's ollama instead of Anthropic.
# Usage: claude-local [model] [claude args...] — model defaults to gpt-oss
function claude-local -d "claude-code on DJServer's local LLMs"
    set -l model gpt-oss:20b
    # first arg is a model name unless it looks like a flag
    if set -q argv[1]; and not string match -q -- '-*' $argv[1]
        set model $argv[1]
        set -e argv[1]
    end
    # small-fast-model too, or claude tries to reach a haiku model ollama
    # doesn't have (use the netbird IP here if the LAN one ever changes)
    env ANTHROPIC_BASE_URL=http://192.168.68.254:11434 \
        ANTHROPIC_AUTH_TOKEN=ollama \
        ANTHROPIC_MODEL=$model \
        ANTHROPIC_SMALL_FAST_MODEL=$model \
        claude $argv
end

if status is-interactive
    if not set -q tide_character_color
        tide configure --auto --style=Lean --prompt_colors='True color' \
            --show_time=No --lean_prompt_height='Two lines' \
            --prompt_connection=Disconnected --prompt_spacing=Compact \
            --icons='Many icons' --transient=Yes 2>/dev/null
    end
end
