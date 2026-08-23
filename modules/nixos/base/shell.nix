# Shell and CLI tools - Fish with Tide
{ config, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      # CLI tools and fish plugins
      environment.systemPackages = with pkgs; [
        curl
        wget
        zoxide
        bat
        fishPlugins.tide
      ];

      # Enable fish system-wide
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          # Enable zoxide for fish
          zoxide init fish | source
        '';
      };
    };
}
