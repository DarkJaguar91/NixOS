# Standard NixOS latest kernel. Switched away from CachyOS + scx_lavd after
# the BPF scheduler started showing linkage errors and starving GPU threads,
# causing audio-continues / video-freezes behaviour in Proton games.
{ ... }:
{
  flake.modules.nixos.gaming =
    { lib, pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest.extend (
        kfinal: kprev: {
          # nixpkgs now signs out-of-tree modules with kmodigest during
          # `make modules_install`, and the module aggregator requires each
          # one's <module>.ko.cer. acpi_call (pulled in by handheld-daemon's
          # adjustor) copies its .ko by hand instead, so it's never signed and
          # the system build fails with "cat: misc/acpi_call.ko.cer: No such
          # file or directory". Sign it the same way. Drop once fixed upstream.
          acpi_call = kprev.acpi_call.overrideAttrs (old: {
            installPhase = old.installPhase + ''
              ${lib.getExe pkgs.buildPackages.kmodigest} \
                $out/lib/modules/${kfinal.kernel.modDirVersion}/misc/acpi_call.ko
            '';
          });
        }
      );
    };
}
