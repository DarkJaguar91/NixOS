_: {
  imports = [
    ./hardware.nix
    ./extra-hardware.nix
    ../../modules
  ];

  # Desktop Environments (only enable 1 for best experience)
  dj.cosmic.enable = false;
  dj.gnome.enable = false;
  dj.plasma.enable = true;

  # Apps
  dj.orca-slicer.enable = false;
  dj.steam.enable = true;

  # hardware
  dj.qmk.enable = false;
}
