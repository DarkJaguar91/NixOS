_: {
   programs.nixvim.plugins = { 
     telescope = {
       enable = true;
       extensions.fzf-native.enable = true;
       keymaps = {
         "<leader>ff" = "find_files";
         "<leader>fg" = "live_grep";
       };
     };
   };
}
