_: {
  imports = [
    ./hardware.nix
  ];

  # Desktop Environments (only enable 1 for best experience)
  dj.cosmic.enable = false;
  dj.gnome.enable = false;
  dj.plasma.enable = false;

  # Apps
  dj.orca-slicer.enable = false;
  dj.steam.enable = false;
}
