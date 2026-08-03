# Godot engine: the editor, export templates, and a unix group for sharing
# project/asset directories with group-write permissions.
{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.gamedev =
    { pkgs, ... }:
    {
      # `godot_4` tracks the latest 4.x in nixpkgs (currently 4.7). Use
      # `godot_4-mono` instead if a project needs C# — both ship the same
      # `godot4` binary name, so don't install both at once.
      environment.systemPackages = with pkgs; [
        godot_4
        # Prebuilt export templates matching the editor version, so "Export"
        # works without downloading templates from Godot's servers.
        godot_4-export-templates-bin
        # Inspect/repack .pck files
        godotpcktool
      ];

      # Members can share game project dirs (assets, builds) with group rw.
      users.groups.gamedev = { };
      users.users.${owner.username}.extraGroups = [ "gamedev" ];
    };
}
