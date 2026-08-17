# Niri scrollable-tiling compositor, tracking upstream main via niri-flake.
# The niri-flake module wires up the session, portals, polkit agent, and its
# binary cache. Config lives in dotfiles/niri (live-editable, not generated).
{ config, inputs, ... }:
let
  inherit (config.flake.meta) owner;
  # niri-flake's overlay rebuilds niri against our nixpkgs, which removed
  # libdisplay-info_0_2 (niri's build asserts version 0.2.0). Until niri-flake
  # catches up, use its pre-built packages (against niri's own nixpkgs pin)
  # from the flake output instead of the overlay.
  niri-pkgs = inputs.niri.packages.x86_64-linux;
in
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri = {
        enable = true;
        package = niri-pkgs.niri-unstable;
      };

      environment.systemPackages = [
        # niri auto-spawns xwayland-satellite for X11 apps (Steam, games)
        niri-pkgs.xwayland-satellite-unstable
      ];

      # xdg-desktop-portal-gnome's FileChooser is implemented by nautilus
      # (D-Bus activated at runtime), which would force nautilus as the file
      # manager. Route FileChooser to the self-contained portal-gtk dialog
      # instead; the gnome portal stays for screencast/remote-desktop. This
      # /etc copy shadows the niri package's niri-portals.conf entirely, so
      # it restates the upstream entries too.
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      environment.etc."xdg/xdg-desktop-portal/niri-portals.conf".text = ''
        [preferred]
        default=gnome;gtk;
        org.freedesktop.impl.portal.Access=gtk;
        org.freedesktop.impl.portal.Notification=gtk;
        org.freedesktop.impl.portal.Secret=gnome-keyring;
        org.freedesktop.impl.portal.FileChooser=gtk;
      '';

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
