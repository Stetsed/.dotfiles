-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
return {
  vim.g.completeopt == "menu, menuone, noselect, noinsert",
  vim.g.wrap == true,
  vim.g.rustaceanvim == { "tools" == { enable_clippy = false } },
  vim.diagnostic.config({ virtual_text = false }),
}
