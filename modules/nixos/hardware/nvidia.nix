# Headless NVIDIA (the server's RTX 2000 Ada): registers the driver,
# blacklists nouveau, and sets up /dev/nvidia* — no display server required.
{
  flake.modules.nixos.nvidia =
    { config, ... }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware = {
        graphics.enable = true;

        nvidia = {
          open = true; # Ada and newer use the open kernel module
          modesetting.enable = true;
          nvidiaSettings = false; # GUI tool, useless headless
          package = config.boot.kernelPackages.nvidiaPackages.production;
        };

        # generates CDI specs so containers can request the GPU
        # (--device=nvidia.com/gpu=all)
        nvidia-container-toolkit.enable = true;
      };
    };
}
