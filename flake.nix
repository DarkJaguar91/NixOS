{
  description = "Brandon's dendritic NixOS configuration";

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

    # Noctalia ecosystem
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbriel = {
      url = "github:noctalia-dev/umbriel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
