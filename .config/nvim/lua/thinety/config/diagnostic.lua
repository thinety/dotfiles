vim.diagnostic.config({
  float = { source = true },
})

vim.keymap.set("n", "<Leader>d", function()
  vim.diagnostic.config({
    virtual_lines = { current_line = true }
  })
end, { desc = "Show diagnostic messages" })

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("thinety.hide-diagnostics", { clear = true }),
  callback = function()
    vim.diagnostic.config({
      virtual_lines = false
    })
  end,
})
