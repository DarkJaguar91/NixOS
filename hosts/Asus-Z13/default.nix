{gpuType, ...}: {
  imports = [
    ./hardware.nix
    ../../drivers/${gpuType}
    ./host-packages.nix
    ../../modules/core
  ];
}
