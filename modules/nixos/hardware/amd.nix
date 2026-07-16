{
  flake.modules.nixos.amd = {
    services.xserver.videoDrivers = [ "amdgpu" ];

    # load amdgpu in the initrd for flicker-free early KMS
    hardware.amdgpu.initrd.enable = true;
    hardware.amdgpu.opencl.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true; # 32-bit games
    };
  };
}
