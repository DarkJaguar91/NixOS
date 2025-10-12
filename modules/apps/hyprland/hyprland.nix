{ pkgs, ... }:
{
  programs = {
    hyprland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    brave
    eog
    mpv

    hyprpolkitagent
    hyprland-qtutils
    greetd.tuigreet
    swww
    grim
    slurp
    wf-recorder
    wl-clipboard
    swappy

    nwg-displays
    pavucontrol
    pwvucontrol

    brightnessctl
    playerctl
    cliphist
    socat
    ripgrep
    libnotify
  ];
}
