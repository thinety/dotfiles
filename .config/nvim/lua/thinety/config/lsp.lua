vim.keymap.set({ "n", "x" }, "<Leader>fm", function()
  vim.lsp.buf.format()
end, { desc = "LSP: format" })

vim.keymap.set({ "n", "x" }, "<Leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP: code action" })

vim.keymap.set("n", "<Leader>rn", function()
  vim.lsp.buf.rename()
end, { desc = "LSP: rename" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("thinety.lsp-attach", { clear = true }),
  callback = function(event)
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    if client:supports_method("textDocument/foldingRange") then
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("thinety.lsp-highlight-buffer-" .. event.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = event.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = event.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})


vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        targetDir = true,
      },
      check = {
        command = "clippy",
      },
      hover = {
        links = {
          enable = false,
        },
      },
    },
  },
})

vim.lsp.config("tinymist", {
  capabilities = {
    workspace = {
      didChangeConfiguration = {
        dynamicRegistration = true,
      },
    },
  },
  settings = {
    lint = { enabled = true },
    preview = {
      browsing = {
        args = {
          "--data-plane-host=127.0.0.1:0",
          "--open",
        },
      },
    },
  },
  on_init = function(client)
    local export_targets = { "paged", "html" }
    local preview_modes = { "document", "slide" }

    local function update_settings(settings)
      client.settings = vim.tbl_deep_extend("force", client.settings, settings)
      client:notify("workspace/didChangeConfiguration", { settings = {} })
    end

    local subcommands = {
      ["set-export-target"] = function(arg)
        assert(vim.list_contains(export_targets, arg))
        update_settings({
          exportTarget = arg,
        })
      end,
      ["set-preview-mode"] = function(arg)
        assert(vim.list_contains(preview_modes, arg))
        update_settings({
          preview = {
            browsing = {
              args = vim.list_extend(
                { "--preview-mode=" .. arg },
                vim.lsp.config["tinymist"].settings.preview.browsing.args
              ),
            },
          },
        })
      end,
      ["preview"] = function()
        client:exec_cmd({
          title = "preview",
          command = "tinymist.startDefaultPreview",
        })
      end,
    }

    local available_subcommands = vim.tbl_keys(subcommands)
    local subcommands_complete = {
      ["set-export-target"] = export_targets,
      ["set-preview-mode"] = preview_modes,
    }

    vim.api.nvim_create_user_command(
      "Tinymist",
      function(opts)
        subcommands[opts.fargs[1]](opts.fargs[2])
      end,
      {
        nargs = "+",
        complete = function(_, line)
          local split = vim.split(line, "%s+")
          if #split == 2 then
            return available_subcommands
          elseif #split == 3 then
            return subcommands_complete[split[2]]
          end
        end
      })
  end,
  on_attach = function(client, buf)
    vim.keymap.set("n", "<leader>tp", function()
      client:exec_cmd({
        title = "pin",
        command = "tinymist.pinMain",
        arguments = { vim.api.nvim_buf_get_name(buf) },
      })
    end, { desc = "Tinymist: pin main file", buf = buf })
  end,
})

vim.lsp.config("cssls", {
  settings = {
    -- do not warn on tailwind at-rules
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
})

vim.lsp.enable({
  "rust_analyzer",
  "gopls",
  "hls",
  "zls",
  "clangd",
  "ty",
  "ruff",
  "lua_ls",
  "tinymist",
  "html",
  "jsonls",
  "cssls",
  "tailwindcss",
  "ts_ls",
  "astro",
  "oxfmt",
  "oxlint",
})


vim.keymap.set("n", "z+", function()
  vim.lsp.enable("harper_ls", not vim.lsp.is_enabled("harper_ls"))
end, { desc = "Toggle grammar checking" })
