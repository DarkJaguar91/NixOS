# The dendritic glue: every module registered as flake.nixosModules."hosts/<name>"
# automatically becomes nixosConfigurations.<name>. Hosts compose feature
# aggregates (base, desktop, gaming, ...) via imports; features live in their
# own files and contribute to those aggregates from anywhere in ./modules.
{
  config,
  inputs,
  lib,
  ...
}:
{
  flake.nixosConfigurations = lib.pipe config.flake.nixosModules [
    (lib.filterAttrs (name: _: lib.hasPrefix "hosts/" name))
    (lib.mapAttrs' (
      name: module:
      lib.nameValuePair (lib.removePrefix "hosts/" name) (
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ module ];
        }
      )
    ))
  ];
}
