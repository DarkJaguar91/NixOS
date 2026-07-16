# Fish with the Tide prompt. Fish plugins installed system-wide are picked up
# through fish's vendor directories, no home-manager needed. Tide's appearance
# lives in fish universal variables (~/.config/fish/fish_variables), which stay
# unmanaged runtime state; config.fish bootstraps a sensible style on first run.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.fish.enable = true;

      environment.systemPackages = [ pkgs.fishPlugins.tide ];

      dots.files.".config/fish/config.fish" = "fish/config.fish";
    };
}
