# nh wraps nixos-rebuild with nicer output (nom) and diffs (nvd), and
# handles generation cleanup so nix.gc isn't needed.
{ config, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.nh = {
        enable = true;
        flake = config.flake.meta.flakePath;
        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nvd
      ];
    };
}
