{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    hyprlock.enable = true;
  };

  environment.systemPackages = with pkgs; [
    appimage-run # App image support
    zed-editor # Gui text editor
    brave # Browser

    brightnessctl # Control screen brightness
    playerctl # Changing volume and media controls
    cliphist # Clipboard manager
    socat # Needed for screenshots
    jstest-gtk # Gamepad tester

    fastfetch # Terminal startup fetcher
    onefetch # info fetcher
    ripgrep # improved grep command
    eza # LS Replacement
    htop # System monitor
    btop # system monitor
    glxinfo # GFX Monitor, used by many other tools
    inxi # CLI system Information tool
    duf # Disk information CLI tool
    lm_sensors # Sensors monitor
    lolcat # Colors in terminal
    lshw # Detailed hardware info tool
    ncdu # Disk usage analyser
    pciutils # Collects info on PCI devices
    usbutils # Tools for USB devices
    pkg-config # Wrapper script allowing package inspection

    killall # Killing instances of programs
    libnotify # Used to send notifications
    unrar # Rar utility
    unzip # Zip utility
    git # Git... duh
    wev # wayland based keytool
    wget # Downloader
    curl # Downloader
    yazi # TUI file manger
    cliphist # History manager

    nixd # nix language server
    nil # Nix language server
    nixfmt-rfc-style # Formatting nix files
    ffmpeg
    bc
    jq
    
    spotify-player
    libsixel
    kitty
    youtube-tui
    mpv
  ];
}
