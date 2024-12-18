-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.completeopt = "menu, menuone, noselect, noinsert"

local opt = vim.opt
opt.wrap = true
opt.linebreak = false
opt.spelllang = { "en_us", "nl" }
