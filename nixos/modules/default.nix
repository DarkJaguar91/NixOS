{ ... }: {
  imports = [
    ./system.nix
    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./users
    ./packages.nix
    ./sound.nix
    ./fonts.nix
    ./services.nix
    ./steam.nix

    ./hyprland
  ];
}
