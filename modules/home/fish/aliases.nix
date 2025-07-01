{ host, ... }:
{
  programs.fish.shellAliases = {
    sv = "sudo nvim";
    v = "nvim";
    c = "clear";
    fr = "nh os switch --hostname ${host}";
    fu = "nh os switch --hostname ${host} --update";
    ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    ls = "eza --icons --group-directories-first -1";
    ll = "eza --icons -lh --group-directories-first -1 --no-user --long";
    la = "eza --icons -lah --group-directories-first -1";
    tree = "eza --icons --tree --group-directories-first";
  };
}
