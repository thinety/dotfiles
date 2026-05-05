local function github(repo)
  return "https://github.com/" .. repo
end

local plugins = {
  {
    github("nvim-treesitter/nvim-treesitter"),
    build = function()
      require("nvim-treesitter").update()
    end,
  },
  {
    github("neovim/nvim-lspconfig"),
  },
  {
    github("folke/tokyonight.nvim"),
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  {
    github("nvim-lualine/lualine.nvim"),
    dependencies = {
      { github("nvim-tree/nvim-web-devicons") },
    },
    config = function()
      require("lualine").setup({
        sections = {
          lualine_c = {
            { "filename", path = 1 },
          },
        },
        inactive_sections = {
          lualine_c = {
            { "filename", path = 1 },
          },
        },
      })
    end,
  },
  {
    github("stevearc/oil.nvim"),
    dependencies = {
      { github("nvim-tree/nvim-web-devicons") },
    },
    config = function()
      local oil = require("oil")

      oil.setup({
        view_options = {
          show_hidden = true,
        },
      })

      vim.keymap.set("n", "-", function()
        oil.open()
      end, { desc = "Open parent directory" })
    end,
  },
  {
    github("saghen/blink.cmp"),
    version = vim.version.range("*"), -- use a release tag to download pre-built binaries
    dependencies = {
      { github("rafamadriz/friendly-snippets") },
    },
    config = function()
      require("blink.cmp").setup({
        signature = { enabled = true },
      })
    end,
  },
  {
    github("folke/noice.nvim"),
    dependencies = {
      { github("MunifTanjim/nui.nvim") },
    },
    config = function()
      require("noice").setup({
        cmdline = { enabled = false },
        messages = { enabled = false },
        popupmenu = { enabled = false },
        lsp = {
          signature = { auto_open = { enabled = false } },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        views = {
          mini = {
            position = { row = -2 },
          },
          hover = {
            border = { padding = { 1, 2 } },
            position = { row = 2 },
          },
        },
      })
    end,
  },
  {
    github("folke/snacks.nvim"),
    config = function()
      local snacks = require("snacks")

      snacks.setup({
        bigfile = {},
        input = {},
        picker = {},
      })

      local keymaps = {
        {
          "<Leader>ss",
          function()
            snacks.picker.smart()
          end,
          desc = "Search smart",
        },
        {
          "<Leader>sf",
          function()
            snacks.picker.files()
          end,
          desc = "Search files",
        },
        {
          "<Leader>sg",
          function()
            snacks.picker.grep()
          end,
          desc = "Search with grep",
        },
        {
          "<Leader>sd",
          function()
            snacks.picker.diagnostics()
          end,
          desc = "Search diagnostics",
        },
        {
          "<Leader>sr",
          function()
            snacks.picker.resume()
          end,
          desc = "Search resume",
        },
        {
          "<Leader>sp",
          function()
            snacks.picker.pickers()
          end,
          desc = "Search pickers",
        },
        {
          "gr",
          function()
            snacks.picker.lsp_references()
          end,
          desc = "LSP: go to references",
        },
        {
          "gd",
          function()
            snacks.picker.lsp_definitions()
          end,
          desc = "LSP: go to definitions",
        },
        {
          "gD",
          function()
            snacks.picker.lsp_declarations()
          end,
          desc = "LSP: go to declarations",
        },
        {
          "gi",
          function()
            snacks.picker.lsp_implementations()
          end,
          desc = "LSP: go to implementations",
        },
        {
          "gt",
          function()
            snacks.picker.lsp_type_definitions()
          end,
          desc = "LSP: go to type definitions",
        },
      }

      for _, map in ipairs(keymaps) do
        vim.keymap.set(map.mode or "n", map[1], map[2], {
          desc = map.desc,
        })
      end
    end,
  },
}

local build_fns = {}
local specs = {}
local config_fns = {}

for _, plugin in ipairs(plugins) do
  if plugin.build then
    build_fns[plugin[1]] = plugin.build
  end

  table.insert(specs, {
    src = plugin[1],
    version = plugin.version,
  })
  for _, dependency in ipairs(plugin.dependencies or {}) do
    table.insert(specs, {
      src = dependency[1],
      version = dependency.version,
    })
  end

  if plugin.config then
    table.insert(config_fns, plugin.config)
  end
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("thinety.pack-changed", { clear = true }),
  callback = function(event)
    local src, kind = event.data.spec.src, event.data.kind
    if build_fns[src] and (kind == "install" or kind == "update") then
      if not event.data.active then
        vim.cmd.packadd(event.data.spec.name)
      end
      build_fns[src]()
    end
  end,
})

vim.pack.add(specs)

for _, config_fn in ipairs(config_fns) do
  config_fn()
end
