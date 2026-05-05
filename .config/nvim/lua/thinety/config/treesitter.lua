local treesitter_plugin = require("nvim-treesitter")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("thinety.start-treesitter", { clear = true }),
  callback = function(event)
    local filetype = event.match
    local language = assert(vim.treesitter.language.get_lang(filetype))

    if not vim.treesitter.language.add(language) then
      if vim.list_contains(treesitter_plugin.get_available(), language) then
        treesitter_plugin.install(language)
      end
      return
    end

    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

    vim.treesitter.start()
  end,
})
