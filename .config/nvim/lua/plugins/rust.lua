return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      on_attach = function(_, bufnr)
        local mode = { "n", "v" }
        vim.keymap.set("n", "<leader>dr", function()
          vim.cmd.RustLsp("debuggables")
        end, { desc = "Rust Debuggables", buffer = bufnr })
        vim.keymap.set(mode, "<leader>ce", function()
          vim.cmd.RustLsp({ "explainError", "cycle" })
        end, { desc = "Explain Error", buffer = bufnr })
        vim.keymap.set(mode, "<leader>cd", function()
          vim.cmd.RustLsp({ "renderDiagnostic" })
        end, { desc = "Get diagnostics", buffer = bufnr })
      end,
      default_settings = {
        -- rust-analyzer language server configuration
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Add clippy lints for Rust.
          checkOnSave = true,
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
        },
      },
    },
  },
}
