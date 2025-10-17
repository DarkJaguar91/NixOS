{
  description = "DJ OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    jovian-nixos.url = "github:jovian-experiments/jovian-nixos";
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
      nixConfigPath = "/home/${usr.login}/.config/nixos";
    in
    {
      nixosConfigurations = {
        DellXPS13 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            inherit nixConfigPath;
            host = "DellXPS13";
            gpuType = "intel";
          };
          modules = [
            ./hosts/DellXPS13
          ];
        };
        DarkJaguar-NixOS = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            inherit nixConfigPath;
            host = "DarkJaguar-NixOS";
            gpuType = "nvidia";
          };
          modules = [
            ./hosts/DarkJaguar-NixOS
          ];
        };
        AsusZ13 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit usr;
            inherit nixConfigPath;
            host = "AsusZ13";
            gpuType = "amd";
          };
          modules = [
            ./hosts/AsusZ13
          ];
        };
      };
    };
}
