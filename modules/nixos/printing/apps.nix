{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        freecad
        # openscad-unstable would be preferable (nixpkgs' "stable" openscad
        # tracks a 2021 release) but currently fails to link: ld.lld rejects
        # a non-null-terminated .debug_gdb_scripts section regardless of
        # LTO/build type, a toolchain bug rather than anything fixable here.
        openscad
        orca-slicer
      ];

      # USB-serial access for printers connected directly rather than over the network
      users.users.${owner.username}.extraGroups = [ "dialout" ];
    };
}
