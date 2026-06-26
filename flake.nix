{
  description = "Brandon's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      mangowc,
      ...
    }:
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
    in
    {
      nixosConfigurations = {
        AsusZ13 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = nixosModules ++ [
            mangowc.nixosModules.mango
            ./hosts/AsusZ13
            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.brandon = import ./users/brandon;
                  sharedModules = [ nixvim.homeModules.nixvim ];
                  extraSpecialArgs = {
                    inherit nixpkgs;
                    nixosConfig = config;
                  };
                };
              }
            )
          ];
        };
      };
    };
}
