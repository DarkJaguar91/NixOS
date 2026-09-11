{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
      };

      programs.gamescope.enable = true;
      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        protonplus
        mangohud
        goverlay
      ];
    };
}
