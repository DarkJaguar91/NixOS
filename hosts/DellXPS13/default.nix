_: {
  imports = [
    ./hardware.nix
    ../../modules
  ];

  # Desktop Environments (only enable 1 for best experience)
  dj.cosmic.enable = true;
  dj.gnome.enable = false;
}
