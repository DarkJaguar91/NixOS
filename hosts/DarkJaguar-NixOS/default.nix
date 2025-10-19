_: {
  imports = [
    ./hardware.nix
    ./extra-hardware.nix
    ../../modules
  ];

  dj = {
    # Desktop Environments
    cosmic.enable = false;
    gnome.enable = false;
    plasma.enable = false;
    niri.enable = true;

    # Apps
    btop.enable = true;
    cava.enable = true;
    kitty.enable = true;
    orca-slicer.enable = true;
    steam.enable = true;
    tmux.enable = true;

    # Hardware
    qmk.enable = true;
  };
}
