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
    findutils
    ffmpeg
    openssl

    wget
    curl
    git
    fastfetch
    (mpv.override {scripts = [mpvScripts.mpris];}) # with tray


    neovim
    clang

    orca-slicer
    spotify
    discord
  ];
}
