{ pkgs, ... }: {
  programs = {
    hyprland.enable = true;
    waybar.enable = true;
    hyprlock.enable = true;
    nm-applet.indicator = true;
    dconf.enable = true;

  };
  environment.systemPackages = with pkgs; [
    kitty # Terminal
    brave # browser
    zed-editor # GUI editor

    rofi-wayland # Spotlightesc tool
    hypridle # Idle toolchain
    swww # Wallpaper thingy
    jq # needed for some wallpaper tooling
    ags # Desktop overview
    libnotify # notification tool used by scripts
    bc # ?? TODO Determine what this is

    pavucontrol # Sound control gui
    pamixer # Sound control cli toolkit
    brightnessctl # Brightness control tool
    playerctl # Music control tool
    nwg-displays # Monitor config GUI
    nwg-look
    wl-clipboard # Clipboard loader
    networkmanagerapplet # Network manager applet
    swappy
    swaynotificationcenter
    wallust
    wlogout
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
