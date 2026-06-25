require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Telescope live grep" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<C-\\>", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<C-h>", "<C-w>h", { desc = "Move right" })
map("n", "<C-j>", "<C-w>j", { desc = "Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move left" })
