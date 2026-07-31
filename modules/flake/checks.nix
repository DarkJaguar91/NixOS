# `nix flake check` evaluates every host end-to-end without building it: each
# check just records the host's toplevel .drv path, which forces full module
# evaluation (catches bad options, type errors, broken overlays). The string
# context MUST be discarded — otherwise the .drv becomes a build input and the
# "check" would build the entire system (and happily OOM a 23GB machine).
{ config, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = lib.mapAttrs' (
        name: host:
        let
          toplevel = builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath;
        in
        lib.nameValuePair "eval-${name}" (
          pkgs.runCommand "eval-${name}" { } ''
            echo "${toplevel}" > $out
          ''
        )
      ) config.flake.nixosConfigurations;
    };
}
