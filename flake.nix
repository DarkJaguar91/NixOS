{
  description = "DJ OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      theme = null;
      usr = {
        name = "Brandon Talbot";
        login = "brandon";
        email = "bjtal91@gmail.com";
      };
    in
    {
      nixosConfigurations = {
        Asus-Z13 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            inherit theme;
            host = "Asus-Z13";
            gpuType = "amd";
          };
          modules = [
            ./hosts/Asus-Z13
          ];
        };
        DarkJaguar-NixOS = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            inherit theme;
            host = "DarkJaguar-NixOS";
            gpuType = "nvidia";
          };
          modules = [
            ./hosts/DarkJaguar-NixOS
          ];
        };
      };
    };
}
