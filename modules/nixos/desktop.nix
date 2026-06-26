{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.desktop;
in

{
  options.modules.desktop = {
    enable = lib.mkEnableOption "desktop environment support";

    displayManager = lib.mkOption {
      type = lib.types.enum [
        "sddm"
        "gdm"
      ];
      default = "sddm";
      description = "Display manager to use for login.";
    };

    plasma.enable = lib.mkEnableOption "KDE Plasma 6 desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        xkb.layout = "us";
      };
      displayManager = {
        sddm = {
          enable = cfg.displayManager == "sddm";
          wayland.enable = cfg.displayManager == "sddm";
        };
        gdm.enable = cfg.displayManager == "gdm";
      };
      desktopManager.plasma6.enable = cfg.plasma.enable;
      printing.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
    };

    security.rtkit.enable = true;

    environment.systemPackages = with pkgs; [
      brave
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-color-emoji
      inter
    ];
  };
}
