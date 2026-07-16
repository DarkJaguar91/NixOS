{
  description = "Brandon's dendritic NixOS configuration";

  # The niri/chaotic modules configure these caches in the built system, but
  # the *first* build on a fresh machine happens before that config exists.
  # Declaring them here lets nix offer them during that first build.
  nixConfig = {
    extra-substituters = [
      "https://niri.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Loads every file under ./modules as a flake-parts module.
    import-tree.url = "github:vic/import-tree";

    # CachyOS kernel and other bleeding-edge packages, with binary cache.
    # Deliberately NOT following our nixpkgs: their cache is built against
    # their own pin, so following would mean compiling kernels locally.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Same reasoning: both flakes provide binary caches keyed to their own
    # nixpkgs pins.
    niri.url = "github:sodiboo/niri-flake";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
