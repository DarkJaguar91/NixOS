{ config, lib, ... }:

{
  options.modules.gpu.amd.enable = lib.mkEnableOption "AMD GPU";

  config = lib.mkIf config.modules.gpu.amd.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.opencl.enable = true;

    boot.initrd.kernelModules = [ "amdgpu" ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    };
  };
}
