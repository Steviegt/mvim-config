-- ~/.config/nvim/lua/stefan/lsp.lua
return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Mason Setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- Liste der zu installierenden Language Server
        ensure_installed = {
          "lua_ls",
          "tsserver",
          "eslint",  -- Verwende eslint hier
        },
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- TypeScript Tools Setup
      require("typescript-tools").setup{
        capabilities = capabilities,
        settings = {
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        }
      }

      -- Language Server Konfiguration für lua_ls
      require("lspconfig").lua_ls.setup({
        capabilities = capabilities,
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT'
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })

      -- ESLint Konfiguration
      require("lspconfig").eslint.setup({
        capabilities = capabilities,
        settings = {
          workingDirectories = { mode = "auto" },
        },
        on_attach = function(client, bufnr)
          -- EslintFixAll Befehl definieren
          vim.api.nvim_buf_create_user_command(bufnr, 'EslintFixAll', function()
            local params = vim.lsp.util.make_range_params()
            params.context = { only = { "source.fixAll.eslint" } }
            local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
            if not result or vim.tbl_isempty(result) then
              vim.notify("EslintFixAll: No code actions available", vim.log.levels.WARN)
              return
            end
            for _, res in pairs(result) do
              if res.result then
                for _, action in pairs(res.result) do
                  if action.edit or type(action.command) == "table" then
                    if action.edit then
                      vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                    end
                    if type(action.command) == "table" then
                      vim.lsp.buf.execute_command(action.command)
                    end
                  end
                end
              end
            end
          end, { desc = "Fix all eslint issues" })

          -- Befehl zum Fixen des aktuellen Fehlers definieren
          vim.api.nvim_buf_create_user_command(bufnr, 'EslintFixCurrent', function()
            local params = vim.lsp.util.make_range_params()
            params.context = { diagnostics = { vim.diagnostic.get(bufnr, { lnum = vim.fn.line('.') - 1 })[1] } }
            local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
            if not result or vim.tbl_isempty(result) then
              vim.notify("EslintFixCurrent: No code actions available for the current error", vim.log.levels.WARN)
              return
            end
            for _, res in pairs(result) do
              if res.result then
                for _, action in pairs(res.result) do
                  if action.edit or type(action.command) == "table" then
                    if action.edit then
                      vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                    end
                    if type(action.command) == "table" then
                      vim.lsp.buf.execute_command(action.command)
                    end
                  end
                end
              end
            end
          end, { desc = "Fix the current eslint issue" })

          -- Automatisches Fixen beim Speichern
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.cmd("EslintFixAll")
            end
          })
        end
      })

    end
  }
}

