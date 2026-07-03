{ lib, config, ... }:
{
  options.modules.streaming = {
    plex.enable = lib.mkEnableOption "Plex Media Server";
    jellyfin.enable = lib.mkEnableOption "Jellyfin";
  };

  config = lib.mkMerge [
    (lib.mkIf
      (config.modules.streaming.plex.enable || config.modules.streaming.jellyfin.enable)
      {
        users.groups.media = { };
        hardware.graphics.enable = true; # VAAPI transcoding
      }
    )

    (lib.mkIf config.modules.streaming.plex.enable {
      services.plex = {
        enable = true;
        group = "media";
        openFirewall = true; # 32400
        dataDir = "/fast/appdata/plex";
        # accelerationDevices defaults to "*"; NVENC just needs the driver
        # plus Plex Pass (enable HW transcoding in Plex settings)
      };
    })

    (lib.mkIf config.modules.streaming.jellyfin.enable {
      services.jellyfin = {
        enable = true;
        group = "media";
        openFirewall = true; # 8096
        dataDir = "/fast/appdata/jellyfin";
      };
    })

    (lib.mkIf (config.modules.streaming.jellyfin.enable && config.modules.gpu.nvidia.enable) {
      # writes NVENC into encoding.xml on first start
      services.jellyfin.hardwareAcceleration = {
        enable = true;
        type = "nvenc";
        device = "/dev/nvidia0";
      };
      # the module's DeviceAllow only covers the device above; NVENC also
      # needs the control/uvm nodes
      systemd.services.jellyfin.serviceConfig.DeviceAllow = [
        "/dev/nvidiactl rw"
        "/dev/nvidia-uvm rw"
        "/dev/nvidia-uvm-tools rw"
        "/dev/nvidia-modeset rw"
      ];
    })
  ];
}
