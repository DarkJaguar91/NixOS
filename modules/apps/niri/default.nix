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
    dj.rofi.enable = lib.mkForce true;
    dj.waybar.enable = lib.mkForce true;
    dj.wal.enable = lib.mkForce true;
    dj.ui-scripts.enable = lib.mkForce true;
    dj.wallpapers.enable = lib.mkForce true;
    dj.yazi.enable = lib.mkForce true;

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            user = usr.login;
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session"; # start Hyprland with a TUI login manager
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
    '';
  };
}
