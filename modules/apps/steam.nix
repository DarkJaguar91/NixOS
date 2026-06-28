{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.steam.enable = lib.mkEnableOption "Steam gaming setup";

  config = lib.mkIf config.modules.steam.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      mangohud
      protonplus
      protontricks
      goverlay
    ];
  };
}
