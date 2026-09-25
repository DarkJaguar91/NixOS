# Pin AMD GPUs to their highest DPM level only while a gamemode session is
# active, so shader compilation and frame submission never wait on a clock
# ramp in-game, but the GPU still idles down on the desktop.
#
# gamemode's custom scripts run as the user, and
# power_dpm_force_performance_level ships root:root 0644, so grant the video
# group write access to it (same approach as ./backlight.nix).
{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.amdgpu-gamemode-perf =
    { pkgs, ... }:
    let
      setLevel =
        level:
        pkgs.writeShellScript "amdgpu-perf-${level}" ''
          for f in /sys/class/drm/card*/device/power_dpm_force_performance_level; do
            [ -w "$f" ] && echo ${level} > "$f"
          done
          exit 0
        '';
    in
    {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{DEVTYPE}=="drm_minor", DRIVERS=="amdgpu", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/device/power_dpm_force_performance_level", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/device/power_dpm_force_performance_level"
      '';

      users.users.${owner.username}.extraGroups = [ "video" ];

      programs.gamemode.settings.custom = {
        start = "${setLevel "high"}";
        end = "${setLevel "auto"}";
      };
    };
}
