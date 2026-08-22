{ config, pkgs, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/brandon/.config/nixos";
  };
}
