{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraEnv = {
            TZ = "America/Los_Angeles";
            TZDIR = "/usr/share/zoneinfo";
          };
        };
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
