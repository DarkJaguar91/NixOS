{ gpuType, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../../drivers/${gpuType}
    ../../modules
  ];
  environment.systemPackages = with pkgs; [
    # Add any specific packages needed for this host
  ];
}
