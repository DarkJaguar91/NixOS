{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations.AsusZ13 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs lib; };
        modules = [
          ./hosts/AsusZ13
        ];
      };
    };
}
