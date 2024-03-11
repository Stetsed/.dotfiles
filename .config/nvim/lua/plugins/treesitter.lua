return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, {
        "dockerfile",
        "git_config",
        "make",
        "toml",
        "vimdoc",
        "svelte",
        "yuck",
        "astro",
        "terraform",
      })
    end
  end,
}
