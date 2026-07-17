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
      ];

      dots.files = {
        ".config/niri/config.kdl" = "niri/config.kdl";
        ".config/niri/keybinds.kdl" = "niri/keybinds.kdl";
        ".config/niri/outputs.kdl" = "niri/outputs.kdl";
        ".config/niri/rules.kdl" = "niri/rules.kdl";
        ".config/niri/scripts/record-region.sh" = "niri/scripts/record-region.sh";
      };

      # noctalia's niri template writes theme colors here; config.kdl includes
      # it, so it must exist even before noctalia first generates it
      systemd.tmpfiles.rules = [
        "f /home/${owner.username}/.config/niri/noctalia.kdl 0644 ${owner.username} users -"
      ];
    };
}
