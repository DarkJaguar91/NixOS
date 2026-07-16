{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        # tzdata 2026b broke Wine's Windows-timezone mapping for
        # America/Vancouver; LA keeps Pacific wall time. TODO: test a Proton
        # game that reads local time without this, then delete.
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
