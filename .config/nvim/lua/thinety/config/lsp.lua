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
