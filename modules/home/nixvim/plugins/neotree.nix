_: {
  programs.nixvim = {
    plugins = {
      neo-tree = {
        enable = true;
      };
    };

    keymaps = [
      {
	mode = "n";
	key = "<leader>fd";
	action = "<cmd>Neotree<cr>";
      }
    ];
  };
}
