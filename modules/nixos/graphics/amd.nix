# AMD GPU configuration
# Minimal, correct setup per the NixOS manual.
{ lib, ... }:
{
  flake.nixosModules."graphics/amd" =
    { ... }:
    {
      # Load the amdgpu kernel module early for KMS (better boot resolution,
      # smoother handoff to the Wayland compositor / display manager).
      boot.initrd.kernelModules = [ "amdgpu" ];

      # Declare the X11 / XWayland driver (amdgpu is auto-detected on most
      # hardware, but setting it explicitly prevents fallbacks to modesetting).
      services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];
    };
}
