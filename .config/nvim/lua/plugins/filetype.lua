return {
  "nathom/filetype.nvim",
  config = function()
    require("filetype").setup({
      overrides = {
        extensions = {
          tf = "terraform",
          tfvars = "terraform",
          tfstate = "json",
        },
      },
    })
  end,
}
