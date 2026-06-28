{ config, lib, ... }: {
  options.modules.gpu.amd.enable = lib.mkEnableOption "AMD GPU";

  config = lib.mkIf config.modules.gpu.amd.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.amdgpu.opencl.enable = true;

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
