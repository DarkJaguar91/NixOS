# Plex and Jellyfin media servers.
{
  flake.modules.nixos.server =
    { config, lib, ... }:
    {
      users.groups.media = { };
      hardware.graphics.enable = true; # VAAPI transcoding

      services.plex = {
        enable = true;
        group = "media";
        openFirewall = true; # 32400
        dataDir = "/fast/appdata/plex";
        # accelerationDevices defaults to "*"; NVENC just needs the driver
        # plus Plex Pass (enable HW transcoding in Plex settings)
      };

      services.jellyfin = {
        enable = true;
        group = "media";
        openFirewall = true; # 8096
        dataDir = "/fast/appdata/jellyfin";
      };

      # NVENC wiring only when the host also imports the nvidia module
      services.jellyfin.hardwareAcceleration =
        lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers)
          {
            # writes NVENC into encoding.xml on first start
            enable = true;
            type = "nvenc";
            device = "/dev/nvidia0";
          };
      # the module's DeviceAllow only covers the device above; NVENC also
      # needs the control/uvm nodes
      systemd.services.jellyfin.serviceConfig.DeviceAllow =
        lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers)
          [
            "/dev/nvidiactl rw"
            "/dev/nvidia-uvm rw"
            "/dev/nvidia-uvm-tools rw"
            "/dev/nvidia-modeset rw"
          ];
    };
}
