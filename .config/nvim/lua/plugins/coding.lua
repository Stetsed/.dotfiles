return {
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },

      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols",
      },
      { "<leader>xl", false },
      { "<leader>xL", false },
      { "<leader>xt", false },
      { "<leader>xT", false },
      { "<leader>xX", false },
      { "<leader>xQ", false },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
        long_message_to_split = true,
        bottom_search = true,
        command_palette = true,
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allTargets = false,
              --target = "x86_64-unknown-linux-gnu"
            },
          },
        },
      },
    },
  },
}
