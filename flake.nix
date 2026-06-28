{
  description = "Brandon's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, mangowc, ... }:
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
