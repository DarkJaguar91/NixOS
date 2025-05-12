{
  description = "DarkJaguar-NixOS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    host = "DarkJaguar-NixOS";
    profile = "nvidia";
    username = "brandon";
  in {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          inherit host;
          inherit profile;
        };
        modules = [./profiles/${profile}.nix];
      };
    };
  };
}
