{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
      smartindent = true;
      smartcase = true;
      cursorline = true;
      termguicolors = true;
      scrolloff = 8;
      sidescrolloff = 8;
    };

    globals.mapleader = " ";
    keymaps = [
    ];

    plugins = {
      lualine.enable = true;
      web-devicons.enable = true;
    };
  };
}
