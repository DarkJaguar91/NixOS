# Host configuration for DJDesktop
# This is a new machine - hardware config needs to be generated.
{ inputs, ... }:
{
  flake.nixosModules."hosts/DJDesktop" =
    { ... }:
    {
      imports = [
        # Base includes: nix, git, nh, shell (fish+tide+cli tools), neovim, network, fonts
        inputs.self.nixosModules.base
        # Desktop: Umbriel + Noctalia + Noctalia Greeter
        inputs.self.nixosModules.desktop
        # Graphics: AMD GPU
        inputs.self.nixosModules."graphics/amd"

        # Hardware configuration - generate with:
        # sudo nixos-generate-config --show-hardware-config > /home/brandon/.config/NixOS/hardware/DJDesktop-hardware.nix
        ../../hardware/DJDesktop-hardware.nix
      ];

      # Bootloader (adjust for your hardware)
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Hostname
      networking.hostName = "DJDesktop";

      # This value determines the NixOS release from which the default
      # settings for stateful data were taken.
      system.stateVersion = "26.05";
    };
}
