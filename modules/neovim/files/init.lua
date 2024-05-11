-- Built from neovim.lua.nix
--
-- Read those docs:
-- https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.expandtab = true

vim.opt.list = true

-- always draw sign column. prevents buffer moving when adding/deleting sign
vim.opt.signcolumn = 'yes'
-- sweet sweet relative line numbers
vim.opt.relativenumber = true
-- and show the absolute line number for the current line
vim.opt.number = true

local space_char = '_'
vim.opt.listchars:append {
  multispace = space_char,
  trail = space_char,
  lead = space_char,
  nbsp = space_char,
  tab = '>~'
}

vim.opt.autoindent = true
vim.opt.smarttab = true
vim.api.nvim_command('filetype plugin indent on')

-- enables mouse in normal, visual, insert modes
vim.opt.mouse = "nvi"
-- use both "*" and "+" registers for yank/paste operations
vim.opt.clipboard = "unnamed,unnamedplus"

vim.api.nvim_set_keymap('n', '<C-n>', ':tabnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':tabprevious<CR>', { noremap = true, silent = true })

-- vim-markdown
-- do not fold automatically things.
vim.g.vim_markdown_folding_disabled = 1

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.go" },
  callback = function()
    vim.opt.expandtab = false
  end
})

-- format on save
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})

vim.cmd.colorscheme "catppuccin"

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
      -- vim.snippet.expand(args.body) -- for neovim 0.10
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  settings = {},
}

lspconfig.nixd.setup {
  capabilities = capabilities,
  settings = {},
}

lspconfig.pyright.setup {
  capabilities = capabilities,
  settings = {},
}

vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = false, silent = true })

vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declarations()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ge', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

-- Formatter
local util = require "formatter.util"
require("formatter").setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    yaml = { require("formatter.filetypes.yaml").yamlfmt },
    nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
  }
}
vim.api.nvim_set_keymap('n', ',a', ':Format<CR>',{noremap = true})

