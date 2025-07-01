{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    hyprland.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    hyprlock.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    fish.enable = true;
  };

  environment.systemPackages = with pkgs; [
    fishPlugins.tide

    appimage-run # App image support

    brave # Browser
    spotify # Music player
    discord # Chat utility
    zed-editor # Gui text editor
    orca-slicer # You guessed it - 3d printing

    greetd.tuigreet # Login manager
    file-roller # Archive manager
    gimp # Image editor
    hyprpicker # UI Color picker
    eog # Image viewer
    nwg-displays # Configure monitors
    pavucontrol # Sound settings panel

    brightnessctl # Control screen brightness
    playerctl # Changing volume and media controls
    cliphist # Clipboard manager
    socat # Needed for screenshots
    jstest-gtk # Gamepad tester

    neovim # Vim editor
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
  ];
}
