{
  description = "DarkJaguar-NixOS";

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
    host = "Asus-Z13"; #gitignore
    profile = "amd"; #gitignore
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
        modules = [
          ./profiles/${profile}.nix
        ];
      };
    };
  };
}
