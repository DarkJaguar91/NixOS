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
      waybar.enable = true;
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
      rofi

      brightnessctl
      playerctl
      pamixer
      xwayland-satellite
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.etc."tmpfiles.d/home-${usr.login}-niri.conf".text = ''
      L+    /home/${usr.login}/.config/waybar                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/waybar
      L+    /home/${usr.login}/.config/niri                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/niri
      L+    /home/${usr.login}/.config/wal                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/wal
      L+    /home/${usr.login}/.config/scripts                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/scripts
      L+    /home/${usr.login}/.config/rofi                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/rofi
    '';
  };
}
