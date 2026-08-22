{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    package = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    fishPlugins.tide
  ];
}
