{
  description = "DJ OS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
  };

  outputs = {nixpkgs, nixos-hardware, ...} @ inputs: let
    system = "x86_64-linux";
    username = "brandon";
  in {
    nixosConfigurations = {
      Asus-Z13 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          host = "Asus-Z13";
          gpuType = "amd";
        };
        modules = [
	  ./hosts/Asus-Z13
	];
      };
    };
  };
}
