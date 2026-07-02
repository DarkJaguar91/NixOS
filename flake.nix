{
  description = "Brandon's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs =
    { nixpkgs, mangowc, jovian-nixos, ... }:
    let
      collectModules =
        dir:
        builtins.concatMap (
          name:
          let
            path = dir + "/${name}";
            type = (builtins.readDir dir).${name};
          in
          if type == "directory" then
            collectModules path
          else if type == "regular" && builtins.match ".*\\.nix" name != null then
            [ path ]
          else
            [ ]
        ) (builtins.attrNames (builtins.readDir dir));

      nixosModules = collectModules ./modules;

      usr = {
        name = "Brandon Talbot";
        login = "brandon";
        email = "bjtal91@gmail.com";
      };
      nixConfigPath = "/home/${usr.login}/NixOS";

      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit usr nixConfigPath host;
          };
          modules = nixosModules ++ [
            mangowc.nixosModules.mango
            jovian-nixos.nixosModules.default
            ./hosts/${host}
          ];
        };
    in
    {
      nixosConfigurations = {
        AsusZ13 = mkHost "AsusZ13";
        DarkJaguar = mkHost "DarkJaguar";
      };
    };
}
