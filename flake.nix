{
  description = "DJ OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      usr = {
        name = "Brandon Talbot";
        login = "brandon";
        email = "bjtal91@gmail.com";
      };
    in
    {
      nixosConfigurations = {
        DellXPS13 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            host = "DellXPS13";
            gpuType = "intel";
          };
          modules = [
            ./hosts/DellXPS13
          ];
        };
      };
    };
}
