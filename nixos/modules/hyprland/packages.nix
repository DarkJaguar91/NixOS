{ pkgs, ... }: let
  python-packages = pkgs.python3.withPackages (ps:
      with ps; [
        requests
        pyquery # needed for hyprland-dots Weather script
        ]
    ); in{
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    waybar.enable = true;
    hyprlock.enable = true;
    nm-applet.indicator = true;
    dconf.enable = true;
    xwayland.enable = true;
  };
  # For Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kitty # Terminal
    brave # browser
    zed-editor # GUI editor

    rofi-wayland # Spotlightesc tool
    hypridle # Idle toolchain
    hyprcursor # cursor themes
    swww # Wallpaper thingy
    jq # needed for some wallpaper tooling
    ags # Desktop overview
    libnotify # notification tool used by scripts
    libappindicator
    bc # ?? TODO Determine what this is
    ags # Desktop overview
    loupe
    gnome-system-monitor
    gtk-engine-murrine
    imagemagick
    libsForQt5.qtstyleplugin-kvantum #kvantum
    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.qtwayland
    kdePackages.qtstyleplugin-kvantum #kvantum
    pavucontrol # Sound control gui
    pamixer # Sound control cli toolkit
    brightnessctl # Brightness control tool
    playerctl # Music control tool
    nwg-displays # Monitor config GUI
    nwg-look
    wl-clipboard # Clipboard loader
    cliphist
    networkmanagerapplet # Network manager applet
    slurp
    swappy
    swaynotificationcenter
    wallust
    wlogout
    grim
    nvtopPackages.full
    polkit_gnome
    unzip
    xarchiver
    yad
    yt-dlp
    python-packages
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };
}
