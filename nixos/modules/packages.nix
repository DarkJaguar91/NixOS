{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish.enable = true;
  };
  environment.systemPackages = with pkgs; [
    htop
    btop
    cava
    eza
    duf
    glxinfo
    lshw
    pciutils
    usbutils
    ripgrep
    file-roller
    inxi
    killall
    lm_sensors
    ncdu

    wget
    curl
    git

    neovim
    clang

    orca-slicer
  ];
}
