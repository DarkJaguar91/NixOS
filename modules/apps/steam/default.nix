{ config, lib, pkgs, ... }: 
with lib;
let 
  cfg = config.dj.steam;
in
{
  options.dj.steam = {
    enable = mkEnableOption ''Steam'';
  };

  config = mkIf cfg.enable {
    programs ={
      steam = {
        enable = true;
  
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  
        gamescopeSession.enable = true;
      };
  
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
  
    environment.systemPackages = with pkgs; [
      mangohud
      goverlay
      protonup-qt
      heroic
    ]; 
  };
}
