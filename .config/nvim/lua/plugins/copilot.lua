return {
  "zbirenbaum/copilot-cmp",
  dependencies = "copilot.lua",
  optscmp = {},
  config = function(_, optscmp)
    local copilot_cmp = require("copilot_cmp")
    copilot_cmp.setup(optscmp)
    -- attach cmp source whenever copilot attaches
    -- fixes lazy-loading issues with the copilot cmp source
    require("lazyvim.util").on_attach(function(client)
      if client.name == "copilot" then
        copilot_cmp._on_insert_enter()
      end
    end)
  end,
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    fix_pairs = false,
  },
}
