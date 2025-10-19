{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
with lib;
let
  cfg = config.dj.niri;
in
{
  options.dj.niri = {
    enable = mkEnableOption "Niri Desktop Manager";
  };

  config = mkIf cfg.enable {
    dj.kitty.enable = lib.mkForce true;
    dj.rofi.enable = lib.mkForce true;
    dj.waybar.enable = lib.mkForce true;
    dj.wal.enable = lib.mkForce true;
    dj.wallpapers.enable = lib.mkForce true;
    dj.ui-scripts.enable = lib.mkForce true;
    dj.yazi.enable = lib.mkForce true;

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            user = usr.login;
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session"; # start Hyprland with a TUI login manager
          };
          steam-deck = {
            user = usr.login;
            command = "steam-deck-ui";
          };
        };
      };
    };

    programs = {
      niri.enable = true;
    };

    environment.systemPackages = with pkgs; [
      tuigreet
      fuzzel
      swaylock
      swayidle
      pwvucontrol
      swaynotificationcenter
      swww
      nautilus

      brightnessctl
      playerctl
      pamixer
      xwayland-satellite

      # Screenshots
      grim
      slurp
      swappy
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.etc."tmpfiles.d/home-${usr.login}-niri.conf".text = ''
      L+    /home/${usr.login}/.config/niri                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/niri
      L+    /home/${usr.login}/.config/swaylock                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/swaylock
      L+    /home/${usr.login}/.config/swayidle                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/swayidle
      L+    /home/${usr.login}/.config/swaync                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/swaync
    '';
  };
}
