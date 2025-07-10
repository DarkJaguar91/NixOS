local map = vim.keymap.set

map("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- Neo Tree
map("n", "<leader>fd", "<cmd>Neotree<cr>", { desc = "Neotree focus" })


-- Telescope
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Find files'})
map('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep'})
