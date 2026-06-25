require "nvchad.options"

local opt = vim.opt
-- o.cursorlineopt ='both' -- to enable cursorline!
opt.relativenumber = true -- relative line numbers
opt.clipboard = "unnamedplus" -- use system clipboard
opt.scrolloff = 8 -- keep 8 lines visible above/below cursor
opt.wrap = false -- don't wrap lines
opt.ignorecase = true -- case insensitive search
opt.smartcase = true -- but case sensitive if you use capitals
opt.expandtab = true -- spaces instead of tabs
opt.shiftwidth = 2 -- indent by 2 spaces
opt.tabstop = 2 -- tab = 2 spaces
