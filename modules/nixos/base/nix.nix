# Nix settings
{ config, lib, ... }:
{
  flake.nixosModules.base = { ... }:
  {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      download-buffer-size = 268435456; # 256 MiB
      max-jobs = 8;
      cores = 0;
    };

    nix.optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };

    nixpkgs.config.allowUnfree = true;
  };
}
