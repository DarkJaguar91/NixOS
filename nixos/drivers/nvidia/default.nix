{ config, lib, pkgs, ... }: {
  # Enable OpenGL support
  hardware.graphics.enable = true;

  # Load XServer Nvidia Driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is needed for NVidia
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
