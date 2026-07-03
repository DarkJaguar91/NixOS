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
      "d /home/${usr.login}/.local/share/Steam 0700 ${usr.login} users -"
      "f /home/${usr.login}/.local/share/Steam/.cef-enable-remote-debugging 0644 ${usr.login} users -"
    ];
  };
}
