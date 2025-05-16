{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, nixos-hardware, ... } @ inputs: let
    system = "x86_64-linux";
    username = "brandon";
  in {
    nixosConfigurations = {
      DarkJaguar-NixOS = nixpkgs.lib.nixosSystem {
        inherit system;
       	specialArgs = {
          inherit inputs;
     	    inherit username;
         	host = "DarkJaguar-NixOS";
          gpuType = "nvidia";
       	};
       	modules = [
          ./hosts/DarkJaguar-NixOS
       	];
      };
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
