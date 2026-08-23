# opencode - AI coding assistant
# NOTE: opencode is not yet in nixpkgs. Install manually or add a custom package.
{ config, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
	opencode
      ];
    };
}
