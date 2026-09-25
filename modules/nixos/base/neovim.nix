# Neovim with the stock LazyVim starter (see dotfiles/nvim). Plugins and
# language servers are managed by lazy.nvim/mason at runtime; this module just
# provides the toolchain they expect to find.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        neovim

        # build/runtime deps for lazy.nvim, treesitter, and mason (unzip and
        # nix-ld, for mason's FHS-linked LSP binaries, come from cli-tools.nix)
        gcc
        gnumake
        curl
        nodejs
        lazygit

        # search tooling LazyVim assumes
        ripgrep
        fd

        # nix language support
        nil
        nixd
        nixfmt
      ];

      environment.variables.EDITOR = "nvim";

      dots.directories.".config/nvim" = "nvim";
    };
}
