{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
    wget
    zoxide
    fzf
    ripgrep
    bat
    nh
    appimage-run
  ];
}
