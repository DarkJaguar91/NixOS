# 3D printing tools for NixOS
{ inputs, ... }:
{
  flake.nixosModules.printing3d =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        orca-slicer       # Slicer for FDM 3D printers
        openscad          # Script-based parametric CAD
        freecad           # Open-source parametric CAD
      ];
    };
}
