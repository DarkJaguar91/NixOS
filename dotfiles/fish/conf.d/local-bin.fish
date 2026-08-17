# ~/.local/bin: pip --user, cargo install, go install, etc. Sourced for every
# fish invocation (interactive, login, or `fish -c`); config.fish's interactive
# block is the wrong place since non-interactive shells need this too.
fish_add_path -g ~/.local/bin