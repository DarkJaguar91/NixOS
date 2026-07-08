{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
{
  options.modules.desktop.niri.enable =
    lib.mkEnableOption "Niri scrollable-tiling Wayland compositor with Noctalia shell";

  config = lib.mkIf config.modules.desktop.niri.enable {
    programs.niri.enable = true;
    modules.desktop.noctalia.enable = lib.mkForce true;

    # Niri has no built-in XWayland; it auto-spawns xwayland-satellite for
    # X11 apps (Steam, games) when the binary is on PATH. lisgd provides
    # touchscreen swipe gestures until niri grows native ones
    environment.systemPackages = [
      pkgs.xwayland-satellite

      # Finds the touchscreen via udev at startup (device numbering shifts
      # between boots) and exits quietly on hosts without one
      (pkgs.writeShellScriptBin "niri-touch-gestures" ''
        for dev in /dev/input/event*; do
          if ${pkgs.systemd}/bin/udevadm info --query=property --name="$dev" \
            | ${pkgs.gnugrep}/bin/grep -q '^ID_INPUT_TOUCHSCREEN=1$'; then
            exec ${pkgs.lisgd}/bin/lisgd -d "$dev" \
              -g "3,LR,*,*,R,niri msg action focus-column-left" \
              -g "3,RL,*,*,R,niri msg action focus-column-right" \
              -g "3,UD,*,*,R,niri msg action focus-workspace-up" \
              -g "3,DU,*,*,R,niri msg action focus-workspace-down"
          fi
        done
      '')
    ];

    # lisgd reads the touchscreen evdev device directly
    users.users.${usr.login}.extraGroups = [ "input" ];

    environment.etc."tmpfiles.d/home-${usr.login}-niri.conf".text = ''
      d  /home/${usr.login}/.config/niri                           0755 ${usr.login} users -
      L+ /home/${usr.login}/.config/niri/config.kdl                -    ${usr.login} -     - ${nixConfigPath}/dots/niri/config.kdl
      L+ /home/${usr.login}/.config/niri/outputs.kdl               -    ${usr.login} -     - ${nixConfigPath}/dots/niri/outputs.kdl
      L+ /home/${usr.login}/.config/niri/style.kdl                 -    ${usr.login} -     - ${nixConfigPath}/dots/niri/style.kdl
      L+ /home/${usr.login}/.config/niri/animations.kdl            -    ${usr.login} -     - ${nixConfigPath}/dots/niri/animations.kdl
      L+ /home/${usr.login}/.config/niri/keybinds.kdl              -    ${usr.login} -     - ${nixConfigPath}/dots/niri/keybinds.kdl
      L+ /home/${usr.login}/.config/niri/rules.kdl                 -    ${usr.login} -     - ${nixConfigPath}/dots/niri/rules.kdl
      f  /home/${usr.login}/.config/niri/noctalia.kdl              0644 ${usr.login} users -
    '';
  };
}
