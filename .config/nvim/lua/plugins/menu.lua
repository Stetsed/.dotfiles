return {
  -- Menu nvim for right click menu
  { "nvzone/volt", lazy = true },
  { "nvzone/minty", lazy = true },
  {
    "nvzone/menu",
    lazy = true,
    keys = {
      {
        "<RightMouse>",
        mode = { "n" },
        function()
          vim.cmd.exec('"normal! \\<RightMouse>"')

          require("menu").open(require("plugins.menus.default"), { mouse = true })
        end,
        desc = "Mouse Menu",
      },
      {
        "<leader>p",
        mode = { "n" },
        function()
          vim.cmd.exec('"normal! \\<RightMouse>"')

          require("menu").open(require("plugins.menus.default"))
        end,
        desc = "Quick Menu",
      },
    },
  },
  -- We are able to get the buffer type with the vim.bo.ft variable, for neotree which is our explorer this is neo-tree
}
