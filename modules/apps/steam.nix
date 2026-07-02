{
  config,
  lib,
  pkgs,
  usr,
  ...
}:

let
  cfg = config.modules.steam;
in
{
  options.modules.steam = {
    enable = lib.mkEnableOption "Steam gaming setup";
    decky.enable = lib.mkEnableOption "Decky Loader plugin manager (desktop mode)";
    steamos = {
      enable = lib.mkEnableOption "Jovian SteamOS mode (gamescope display session, replaces desktop)";
      autostart = lib.mkEnableOption "Auto-start Steam into gamescope session on boot";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        gamescopeSession.enable = true;
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

    # Decky Loader: standalone in desktop mode, no Jovian steam session needed.
    # CEF remote debugging lets Decky inject into Steam's UI.
    jovian.decky-loader.enable = lib.mkIf cfg.decky.enable true;

    systemd.tmpfiles.rules = lib.mkIf cfg.decky.enable [
      "f /home/${usr.login}/.steam/steam/.cef-enable-remote-debugging 0644 ${usr.login} users -"
    ];

    # Full Jovian SteamOS mode: gamescope as the display session.
    # WARNING: this switches Steam to the Steam Deck client (-steamdeck flag).
    # Do not enable unless you want the gaming mode session instead of desktop.
    jovian.steam.enable = lib.mkIf cfg.steamos.enable true;
    jovian.steam.autoStart = lib.mkIf cfg.steamos.autostart true;
    jovian.steam.user = lib.mkIf cfg.steamos.enable usr.login;
    jovian.steam.desktopSession = lib.mkIf cfg.steamos.autostart "mango";
  };
}
