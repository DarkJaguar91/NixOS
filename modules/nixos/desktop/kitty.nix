{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.kitty ];

      dots.directories.".config/kitty" = "kitty";
    };
}
