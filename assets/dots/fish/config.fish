if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fr
    set hostname (cat /etc/hostname)
    nh os switch --hostname "$hostname"
end

function fu
    set hostname (cat /etc/hostname)
    nh os switch --hostname "$hostname" --update
end

alias sv="sudo nvim"
alias v="nvim"
alias c="clear"
alias ncg="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot"
alias ls="eza --icons --group-directories-first -1"
alias ll="eza --icons -lh --group-directories-first -1 --no-user --long"
alias la="eza --icons -lah --group-directories-first -1"
alias tree="eza --icons --tree --group-directories-first"
