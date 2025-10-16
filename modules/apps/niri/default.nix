{
  config,
  lib,
  pkgs,
  usr,
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

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            user = usr.login;
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session"; # start Hyprland with a TUI login manager
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
      pywal
      swww

      brightnessctl
      playerctl
      pamixer
      xwayland-satellite
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.etc."tmpfiles.d/home-${usr.login}-niri.conf".text = ''
      L+    /home/${usr.login}/.config/niri                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/niri
      L+    /home/${usr.login}/.config/wal                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/wal
      L+    /home/${usr.login}/.config/scripts                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/scripts
    '';
  };
}
