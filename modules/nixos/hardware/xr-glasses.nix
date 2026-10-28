# XR glasses (VITURE, XREAL, Rokid, RayNeo) via wheaney's XRLinuxDriver. The
# glasses work as a plain DisplayPort monitor without this; the driver adds
# head tracking, publishing the pose over System V shared memory keyed on
# /tmp/shader_runtime_* files. Leave the user service without PrivateTmp, or
# readers won't find those keys.
{ ... }:
{
  flake.modules.nixos.xr-glasses =
    { lib, pkgs, ... }:
    let
      xr-linux-driver = pkgs.callPackage ../../../pkgs/xr-linux-driver/package.nix { };
      xr-viewer = pkgs.callPackage ../../../pkgs/xr-viewer/package.nix { };
      # umbriel comes from the session's PATH, matching the running compositor
      xr-session = pkgs.writeShellApplication {
        name = "xr-session";
        runtimeInputs = [
          xr-viewer
          pkgs.coreutils
        ];
        text = builtins.readFile ../../../pkgs/xr-viewer/xr-session.sh;
      };
    in
    {
      environment.systemPackages = [
        xr-linux-driver
        xr-viewer
        xr-session
      ];

      # The driver defaults to disabled, and to steering the mouse with head
      # movement once enabled. external_only/none just publishes the pose.
      dots.files.".config/xr_driver/config.ini" = "xr_driver/config.ini";
      # Screen layout for xr-session/xr-viewer; edited with xr-layout
      dots.files.".config/xr-session/layout.toml" = "xr-session/layout.toml";

      # USB/HID access to the glasses, and uinput for the driver's mouse mode
      services.udev.packages = [ xr-linux-driver ];

      systemd.user.services.xr-driver = {
        description = "XR glasses user-space driver";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = lib.getExe xr-linux-driver;
          Restart = "always";
        };
      };
    };
}
