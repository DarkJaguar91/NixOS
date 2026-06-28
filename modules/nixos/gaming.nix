{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf config.modules.gaming.enable {
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
