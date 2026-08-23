# Neovim with the stock LazyVim starter (see dotfiles/nvim). Plugins and
# language servers are managed by lazy.nvim/mason at runtime; this module just
# provides the toolchain they expect to find.
{ config, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        viAlias = true;
      };

      environment.systemPackages = with pkgs; [
        neovim

        # build/runtime deps for lazy.nvim, treesitter, and mason
        gcc
        gnumake
        unzip
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

      # mason downloads prebuilt LSP binaries linked against FHS paths
      programs.nix-ld.enable = true;

      dots.directories.".config/nvim" = "nvim";
    };
}
