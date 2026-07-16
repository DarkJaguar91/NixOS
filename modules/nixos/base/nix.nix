{
  flake.modules.nixos.base = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      download-buffer-size = 268435456; # 256 MiB; large substitutions stall the default
    };

    nixpkgs.config.allowUnfree = true;
  };
}
