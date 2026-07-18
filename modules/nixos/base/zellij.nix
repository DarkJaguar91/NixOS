# Zellij as the terminal multiplexer. Kitty starts straight into a session
# (see dotfiles/kitty/kitty.conf); session serialization means sessions can be
# resumed with `zellij attach` even after a crash or reboot.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zellij ];

      dots.directories.".config/zellij" = "zellij";
    };
}
