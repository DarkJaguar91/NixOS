{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gamescope
    protonplus
    mangohud
  ];

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Gamescope session needs proper kernel modules and udev rules for input
  boot.kernelModules = [ "uinput" ];
}
