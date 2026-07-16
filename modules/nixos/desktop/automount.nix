# USB drives: udisks2 does the mounting, udiskie triggers it automatically on
# hotplug (with a notification through noctalia), gvfs lets nautilus browse
# mtp/smb and show mounts.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.udisks2.enable = true;
      services.gvfs.enable = true;

      systemd.user.services.udiskie = {
        description = "Automount removable media";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.udiskie}/bin/udiskie --automount --notify --no-tray";
          Restart = "on-failure";
        };
      };
    };
}
