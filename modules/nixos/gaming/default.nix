# Gaming configuration for NixOS
{ inputs, ... }:
{
  flake.nixosModules.gaming =
    { config, pkgs, ... }:
    {
      # Steam
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
      };

      # Gaming tools
      environment.systemPackages = with pkgs; [
        gamescope
        mangohud
        goverlay
        protonplus
      ];

      # Enable 32-bit support for Steam and Wine
      hardware.graphics.enable32Bit = true;
    };
}
