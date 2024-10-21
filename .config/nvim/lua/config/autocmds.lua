-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.cmd([[:unmenu PopUp.How-to\ disable\ mouse]])
vim.cmd([[:unmenu PopUp.-1-]])
vim.cmd([[:unmenu PopUp.Select\ All]])

vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
