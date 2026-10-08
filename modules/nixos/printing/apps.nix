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
        # Orca 2.4.2 segfaults on "Slice plate": plate-thumbnail rendering
        # issues glDrawElements with no index buffer bound, so Mesa reads the
        # indices from a NULL pointer (radeonsi; disabling glthread or
        # GALLIUM_THREAD only moves the crash). Running under XWayland avoids
        # it. Drop once fixed upstream:
        # https://github.com/OrcaSlicer/OrcaSlicer/issues/14453
        (symlinkJoin {
          name = "orca-slicer-x11";
          paths = [ orca-slicer ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/orca-slicer --set GDK_BACKEND x11
          '';
        })
      ];

      # USB-serial access for printers connected directly rather than over the network
      users.users.${owner.username}.extraGroups = [ "dialout" ];
    };
}
