require("thinety.config.options")
require("thinety.config.plugins")
require("thinety.config.treesitter")
require("thinety.config.lsp")
require("thinety.config.diagnostic")
require("thinety.config.session")

require("vim._core.ui2").enable({
  msg = {
    cmd = { height = 0.2 },
    pager = { height = 0.5 },
  },
})

vim.cmd.packadd("nvim.undotree")
