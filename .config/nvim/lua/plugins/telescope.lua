return { -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    _TelescopeConfigurationPickers = {
      find_files = {
        opts = {
          hidden = true,
        },
      },
    },
  },
}
