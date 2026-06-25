vim.diagnostic.config({
  float = { source = true },
})

local diagnostic_augroup = "thinety.hide-diagnostics"

vim.keymap.set("n", "<Leader>d", function()
  vim.diagnostic.config({
    virtual_lines = { current_line = true }
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
    group = vim.api.nvim_create_augroup(diagnostic_augroup, { clear = true }),
    callback = function()
      vim.diagnostic.config({
        virtual_lines = false
      })

      -- clear autocmd after running once
      vim.api.nvim_create_augroup(diagnostic_augroup, { clear = true })
    end,
  })
end, { desc = "Show diagnostic messages" })
