{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    firefox.enable = false; # Firefox is not installed by default
    hyprland.enable = true; #someone forgot to set this so desktop file is created
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    amfora # Fancy Terminal Browser For Gemini Protocol
    brave # Brave Browser
    brightnessctl # For Screen Brightness Control
    cliphist # Clipboard manager using rofi menu
    cmatrix # Matrix Movie Effect In Terminal
    cowsay # Great Fun Terminal Program
    duf # Utility For Viewing Disk Usage In Terminal
    eza # Beautiful ls Replacement
    ffmpeg # Terminal Video / Audio Editing
    file-roller # Archive Manager
    gimp # Great Photo Editor
    glxinfo #needed for inxi diag util
    greetd.tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    htop # Simple Terminal Based System Monitor
    hyprpicker # Color Picker
    eog # For Image Viewing
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    mpv # Incredible Video Player
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nixfmt-rfc-style # Nix Formatter
    nwg-displays #configure monitor configs via GUI
    onefetch #provides build info on current system
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    picard # For Changing Music Metadata & Getting Cover Art
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    rhythmbox
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    wget # Tool For Fetching Files With Links
    yazi #TUI File Manager
    zed-editor # GUI based editor
    mangohud # onscreen toolkit
    goverlay # Mangohud configurator
    protonup-qt # Proton toolkit
    spotify # Music
    wev # Key detector
  ];
}
