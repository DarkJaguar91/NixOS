# Standard NixOS latest kernel. Switched away from CachyOS + scx_lavd after
# the BPF scheduler started showing linkage errors and starving GPU threads,
# causing audio-continues / video-freezes behaviour in Proton games.
{ ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
