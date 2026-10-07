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
      url = "git+https://github.com/noctalia-dev/umbriel?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ReShade shaders for vkBasalt: SweetFX effects + the ReShade.fxh headers
    # they include (the "slim" branch is upstream's current minimal set)
    sweetfx = {
      url = "github:CeeJayDK/SweetFX";
      flake = false;
    };

    reshade-shaders = {
      url = "github:crosire/reshade-shaders/slim";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
