{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      # Quickshell (noctalia's launcher) doesn't strip XDG field codes like %U
      # from Exec= lines before handing them to `niri spawn`, so Steam receives
      # a literal "%U", parses it as an invalid steam:// URL, and exits. This
      # user-level desktop entry overrides the system one without %U.
      steamDesktopOverride = pkgs.writeText "steam.desktop" ''
        [Desktop Entry]
        Name=Steam
        Comment=Application for managing and playing games on Steam
        Exec=steam
        Icon=steam
        Terminal=false
        Type=Application
        Categories=Network;FileTransfer;Game;
        MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
      '';
    in
    {
      programs.steam = {
        enable = true;
        # tzdata 2026b changed America/Vancouver's DST rules to ones Wine can't
        # map to a Windows timezone, so Proton apps that look up the local zone
        # fail at launch. Pin Steam to LA (same Pacific wall time). TZDIR must
        # point at a path that exists inside the pressure-vessel container too.
        package = pkgs.steam.override {
          extraEnv = {
            TZ = "America/Los_Angeles";
            TZDIR = "/usr/share/zoneinfo";
          };
        };
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        gamescopeSession.enable = true;
      };

      programs.gamescope = {
        enable = true;
        # capSysNice leaks CAP_SYS_NICE into Steam's bwrap sandbox and kills
        # the gamescope session at launch ("bwrap: Unexpected capabilities")
        capSysNice = false;
      };

      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        mangohud
        goverlay # GUI for tuning mangohud
      ];

      systemd.tmpfiles.rules = [
        "d /home/${owner.username}/.local/share/applications 0755 ${owner.username} users -"
        "L+ /home/${owner.username}/.local/share/applications/steam.desktop - ${owner.username} users - ${steamDesktopOverride}"
      ];
    };
}
