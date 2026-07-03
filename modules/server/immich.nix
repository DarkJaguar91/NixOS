{ lib, config, ... }:
let
  cfg = config.modules.immich;
  nvidia = config.modules.gpu.nvidia.enable;
in
{
  options.modules.immich.enable = lib.mkEnableOption "Immich photo server";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        openFirewall = true; # 2283
        mediaLocation = "/media/photos";
        # null lifts the systemd device sandbox so ffmpeg can reach the
        # /dev/nvidia* nodes (select NVENC under Admin > Video Transcoding)
        accelerationDevices = null;
      };

      # Postgres lives on the fast pool: the fast/immich-pg dataset
      # (mountpoint=legacy) is mounted at /var/lib/postgresql via the
      # fileSystems entry in the DJServer host config.
    })

    (lib.mkIf (cfg.enable && nvidia) {
      # nixpkgs builds immich-machine-learning without CUDA (onnxruntime
      # would compile from source for hours), so run the official CUDA image
      # instead. The server already looks for ML at http://localhost:3003.
      services.immich.machine-learning.enable = false;

      virtualisation.podman.enable = true;

      # podman refuses to create missing bind-mount sources
      systemd.tmpfiles.rules = [ "d /fast/appdata/immich-ml-cache 0755 root root -" ];

      virtualisation.oci-containers.containers.immich-ml = {
        # tag tracks the server version from nixpkgs so the two stay in sync
        image = "ghcr.io/immich-app/immich-machine-learning:v${config.services.immich.package.version}-cuda";
        ports = [ "127.0.0.1:3003:3003" ];
        volumes = [ "/fast/appdata/immich-ml-cache:/cache" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
    })
  ];
}
