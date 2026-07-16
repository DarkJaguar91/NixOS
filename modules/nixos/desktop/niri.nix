# Niri scrollable-tiling compositor, tracking upstream main via niri-flake.
# The niri-flake module wires up the session, portals, polkit agent, and its
# binary cache. Config lives in dotfiles/niri (live-editable, not generated).
{ config, inputs, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      nixpkgs.overlays = [ inputs.niri.overlays.niri ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      environment.systemPackages = [
        # niri auto-spawns xwayland-satellite for X11 apps (Steam, games)
        pkgs.xwayland-satellite-unstable

        # Touchscreen swipe gestures via lisgd (used on the Z13; exits quietly
        # on hosts without a touchscreen). Finds the device via udev at startup
        # because event numbering shifts between boots.
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
      users.users.${owner.username}.extraGroups = [ "input" ];

      dots.files = {
        ".config/niri/config.kdl" = "niri/config.kdl";
        ".config/niri/keybinds.kdl" = "niri/keybinds.kdl";
        ".config/niri/outputs.kdl" = "niri/outputs.kdl";
        ".config/niri/rules.kdl" = "niri/rules.kdl";
      };

      # noctalia's niri template writes theme colors here; config.kdl includes
      # it, so it must exist even before noctalia first generates it
      systemd.tmpfiles.rules = [
        "f /home/${owner.username}/.config/niri/noctalia.kdl 0644 ${owner.username} users -"
      ];
    };
}
