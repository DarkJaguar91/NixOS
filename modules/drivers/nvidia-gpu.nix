{ config, lib, ... }: {
  options.modules.gpu.nvidia.enable = lib.mkEnableOption "NVIDIA GPU";

  config = lib.mkIf config.modules.gpu.nvidia.enable {
    # registers the driver, blacklists nouveau, sets up /dev/nvidia* nodes;
    # works headless — no display server required
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      graphics.enable = true;

      nvidia = {
        open = true; # Ada and newer use the open kernel module
        modesetting.enable = true;
        nvidiaSettings = false; # GUI tool, useless on a headless server
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };

      # generates CDI specs so containers can request the GPU
      # (--device=nvidia.com/gpu=all)
      nvidia-container-toolkit.enable = true;
    };
  };
}
