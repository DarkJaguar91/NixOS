# Zellij as the terminal multiplexer. Kitty starts straight into a session
# (see dotfiles/kitty/kitty.conf); session serialization means sessions can be
# resumed with `zellij attach` even after a crash or reboot.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zellij ];

      # Plugins not in nixpkgs, pinned by release; config/layout load them
      # from /etc so the paths survive version bumps without edits there.
      # To update: bump the version in the url, then refresh the hash with
      # `nix store prefetch-file <url>` and `nh os switch`.
      environment.etc."zellij/zjstatus.wasm".source = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.24.0/zjstatus.wasm";
        hash = "sha256-HM7ezh3tYs8+IJvmkM3TnKb7noIo7XGpUfZQf5lWZps=";
      };
      environment.etc."zellij/zjstatus-hints.wasm".source = pkgs.fetchurl {
        url = "https://github.com/b0o/zjstatus-hints/releases/download/v0.1.4/zjstatus-hints.wasm";
        hash = "sha256-k2xV6QJcDtvUNCE4PvwVG9/ceOkk+Wa/6efGgr7IcZ0=";
      };
      environment.etc."zellij/room.wasm".source = pkgs.fetchurl {
        url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
        hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
      };
      environment.etc."zellij/monocle.wasm".source = pkgs.fetchurl {
        url = "https://github.com/imsnif/monocle/releases/download/v0.100.2/monocle.wasm";
        hash = "sha256-TLfizJEtl1tOdVyT5E5/DeYu+SQKCaibc1SQz0cTeSw=";
      };

      dots.directories.".config/zellij" = "zellij";
    };
}
