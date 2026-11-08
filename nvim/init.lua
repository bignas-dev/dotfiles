-- Neovim configuration: single file, built-in `vim.pack` plugin manager.
-- Ported from the Vim config (.vimrc / ~/.vim).
-- nvim-pack-lock.json is gitignored; update plugins with :lua vim.pack.update()

-------------------------------------------------------------------------------
-- Leader
-------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-------------------------------------------------------------------------------
-- Options (from ~/.vimrc and ~/.vim/options.vim)
-------------------------------------------------------------------------------
local opt = vim.opt

opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.autoindent = true
opt.smartindent = true
opt.showmatch = true
opt.backspace = 'indent,eol,start'

opt.wildmenu = true
opt.wildmode = 'full'
opt.wildoptions = 'pum'

opt.number = true
opt.relativenumber = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

opt.background = 'dark'
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.colorcolumn = '80'
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3
opt.winborder = 'rounded'
opt.smoothscroll = true

opt.iskeyword:append('-')
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.updatetime = 50
opt.undofile = true
opt.clipboard = 'unnamedplus'

-- OSC 52 clipboard over SSH (replaces the vim-oscyank plugin)
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
  }
end

-------------------------------------------------------------------------------
-- Autocommands
-------------------------------------------------------------------------------
-- FASM support (from ~/.vimrc)
vim.filetype.add({ extension = { asm = 'fasm' } })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fasm',
  callback = function()
    vim.bo.errorformat = table.concat({
      '%E%f [%l]:',
      '%ZError: %m',
      '%Zerror: %m',
      '%C%.%#',
      '%-G%.%#',
    }, ',')
  end,
})

-------------------------------------------------------------------------------
-- Keymaps (from ~/.vimrc and ~/.vim/keybinds.vim)
-------------------------------------------------------------------------------
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('i', '<C-c>', '<Esc>', { desc = 'Esc in insert mode' })
map('n', 'Q', '<nop>', { desc = 'Disable Ex mode' })

map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })
map('n', 'n', 'nzz', { desc = 'Next search result' })
map('n', 'N', 'Nzz', { desc = 'Previous search result' })

map('n', '<leader>c', '<cmd>vsplit $MYVIMRC<CR>', { desc = 'Edit config' })
map('n', '<leader>rl', '<cmd>source $MYVIMRC<CR>', { desc = 'Reload config' })
map('n', '<leader><leader>', '<cmd>so<CR>', { desc = 'Source current file' })

map('n', 'J', 'mzJ`z', { desc = 'Join lines (keep cursor)' })
map('x', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('x', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
map('n', '<C-n>', ':move .+1<CR>==', { desc = 'Move line down' })
map('n', '<C-p>', ':move .-2<CR>==', { desc = 'Move line up' })
map('x', '<C-n>', ":move '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('x', '<C-p>', ":move '<-2<CR>gv=gv", { desc = 'Move selection up' })
map('x', '<', '<gv', { desc = 'Indent and reselect' })
map('x', '>', '>gv', { desc = 'Indent and reselect' })
map('x', '<leader>i', ':norm 0<CR>', { desc = 'Selection: line start' })
map('x', '<leader>a', ':norm $<CR>', { desc = 'Selection: line end' })
map('x', '<leader>p', '"_dP', { desc = 'Paste without yanking' })
map({ 'n', 'x' }, '<leader>d', '"_d', { desc = 'Delete without yanking' })
map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>s', ':s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>', { desc = 'Substitute word under cursor' })
map('n', '<leader>x', '<cmd>!chmod +x %<CR>', { desc = 'Make file executable' })
map('n', '<leader>af', function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify('Format on save: ' .. tostring(vim.g.autoformat))
end, { desc = 'Toggle format on save' })

map('n', '<leader>o', '<cmd>copen<CR>', { desc = 'Quickfix: open' })
map('n', '<leader>n', '<cmd>cnext<CR>', { desc = 'Quickfix: next' })
map('n', '<leader>p', '<cmd>cprev<CR>', { desc = 'Quickfix: previous' })

-- Location list (`<C-k>` is hover docs in LSP buffers)
map('n', '<C-j>', '<cmd>lnext<CR>', { desc = 'Location list: next' })
map('n', '<C-k>', '<cmd>lprev<CR>', { desc = 'Location list: previous' })
map('n', '<leader>k', '<cmd>lnext<CR>zz', { desc = 'Location list: next (centered)' })
map('n', '<leader>j', '<cmd>lprev<CR>zz', { desc = 'Location list: previous (centered)' })
map('n', '<leader>cl', '<cmd>lclose<CR>', { desc = 'Location list: close' })

-------------------------------------------------------------------------------
-- Plugins (built-in vim.pack)
-------------------------------------------------------------------------------
local gh = function(x)
  return 'https://github.com/' .. x
end

-- Build hooks (vim.pack has no `build` option)
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if name == 'telescope-fzf-native.nvim' then
      vim.system({ 'make' }, { cwd = path }):wait()
    elseif name == 'nvim-treesitter' then
      vim.cmd.packadd('nvim-treesitter')
      pcall(function()
        vim.cmd('TSUpdate')
      end)
    elseif name == 'vim-doge' then
      vim.cmd.packadd('vim-doge')
      pcall(function()
        vim.cmd('call doge#install()')
      end)
    end
  end,
})

vim.pack.add({
  -- Dependencies
  { src = gh('nvim-tree/nvim-web-devicons') },
  { src = gh('nvim-lua/plenary.nvim'), version = vim.version.range('0.1') },
  { src = gh('rafamadriz/friendly-snippets') },

  -- UI
  { src = gh('folke/tokyonight.nvim'), version = vim.version.range('4') },
  { src = gh('nvim-lualine/lualine.nvim') },
  { src = gh('lewis6991/gitsigns.nvim'), version = vim.version.range('2') },
  { src = gh('folke/which-key.nvim'), version = vim.version.range('3') },
  { src = gh('echasnovski/mini.comment') },

  -- Editing
  { src = gh('echasnovski/mini.pairs') },
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  { src = gh('saghen/blink.cmp'), version = vim.version.range('1') },
  { src = gh('kkoomen/vim-doge'), version = vim.version.range('4') },

  -- Navigation
  { src = gh('stevearc/oil.nvim'), version = vim.version.range('2') },
  { src = gh('ibhagwan/fzf-lua') },
  { src = gh('nvim-telescope/telescope.nvim'), version = vim.version.range('0.2') },
  { src = gh('nvim-telescope/telescope-fzf-native.nvim') },

  -- LSP
  { src = gh('neovim/nvim-lspconfig'), version = vim.version.range('2') },
}, { confirm = false, load = true })

-- Convenience: :PackUpdate
vim.api.nvim_create_user_command('PackUpdate', function()
  vim.pack.update()
end, { desc = 'Update plugins (vim.pack)' })

-------------------------------------------------------------------------------
-- UI
-------------------------------------------------------------------------------
require('tokyonight').setup({
  style = 'night',
  styles = { comments = { italic = true }, keywords = { italic = true } },
})
vim.cmd.colorscheme('tokyonight-night')

require('lualine').setup({
  options = {
    theme = 'tokyonight',
    globalstatus = true,
    section_separators = '',
    component_separators = '|',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'diagnostics', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
})

require('gitsigns').setup({})

require('which-key').setup({})
require('which-key').add({
  { '<leader>a', group = 'Actions' },
  { '<leader>c', group = 'Config / quickfix' },
  { '<leader>d', group = 'Delete / docs' },
  { '<leader>f', group = 'Find' },
  { '<leader>g', desc = 'Grep files (telescope)' },
  { '<leader>j', desc = 'Location list: previous' },
  { '<leader>k', desc = 'Location list: next' },
  { '<leader>n', group = 'Next' },
  { '<leader>p', group = 'Previous' },
  { '<leader>r', group = 'Reload / rename' },
  { '<leader>t', group = 'Telescope' },
})

require('mini.comment').setup({})

-------------------------------------------------------------------------------
-- Editing
-------------------------------------------------------------------------------
-- Auto insert pairs
require('mini.pairs').setup({})

-- Syntax highlighting / indentation
require('nvim-treesitter').setup()
require('nvim-treesitter').install({
  'go',
  'gomod',
  'gosum',
  'python',
  'lua',
  'luadoc',
  'vim',
  'vimdoc',
  'bash',
  'json',
  'yaml',
  'toml',
  'markdown',
  'markdown_inline',
  'regex',
  'query',
})
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      pcall(function()
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end
  end,
})

-- Completion (LSP / path / snippets / buffer)
require('blink.cmp').setup({
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  signature = { enabled = true },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
})

map('n', '<leader>dg', '<cmd>DogeGenerate<CR>', { desc = 'Generate docs' })

-------------------------------------------------------------------------------
-- Navigation
-------------------------------------------------------------------------------
require('oil').setup({
  view_options = { show_hidden = true },
  keymaps = {
    ['q'] = 'actions.close',
    ['<Esc>'] = 'actions.close',
  },
  float = {
    max_width = 0.8,
    max_height = 0.8,
  },
})
map('n', '<leader>e', function()
  require('oil').open_float()
end, { desc = 'Oil: file explorer' })
map('n', '<leader>cd', function()
  require('oil').open_float()
end, { desc = 'Oil: file explorer (legacy <leader>cd)' })

-- fzf-lua
map('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find files' })
map('n', '<leader>fo', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recent files' })
map('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Buffers' })
map('n', '<leader>fq', '<cmd>FzfLua quickfix<CR>', { desc = 'Quickfix list' })
map('n', '<leader>fh', '<cmd>FzfLua helptags<CR>', { desc = 'Help tags' })
map('n', '<leader>fs', '<cmd>FzfLua grep_cword<CR>', { desc = 'Grep word under cursor' })
map('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = 'Live grep' })
map('n', '<leader>fc', function()
  require('fzf-lua').grep({ search = vim.fn.expand('%:t:r') })
end, { desc = 'Grep current filename' })
map('n', '<leader>fi', function()
  require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Find files in Neovim config' })

-- Telescope
require('telescope').setup({})
pcall(require('telescope').load_extension, 'fzf')
map('n', '<leader>f', '<cmd>Telescope find_files<CR>', { desc = 'Find files (telescope)' })
map('n', '<leader>g', '<cmd>Telescope live_grep<CR>', { desc = 'Grep files (telescope)' })
map('n', '<leader>tf', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
map('n', '<leader>tg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
map('n', '<leader>tb', '<cmd>Telescope buffers<CR>', { desc = 'Buffers' })
map('n', '<leader>td', '<cmd>Telescope diagnostics<CR>', { desc = 'Diagnostics' })
map('n', '<leader>th', '<cmd>Telescope help_tags<CR>', { desc = 'Help tags' })
map('n', '<leader>ts', '<cmd>Telescope lsp_document_symbols<CR>', { desc = 'Document symbols' })
map('n', '<leader>tr', '<cmd>Telescope lsp_references<CR>', { desc = 'LSP references' })
map('n', '<leader>tz', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Fuzzy search buffer' })

-------------------------------------------------------------------------------
-- LSP: Go + Python diagnostics, hover docs, references
-- Servers are expected on PATH (install yourself):
--   Go:     go install golang.org/x/tools/gopls@latest   (~/go/bin on PATH)
--   Python: ty (pipx install ty / uv tool install ty), and ruff (or your distro package)
-------------------------------------------------------------------------------
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  underline = true,
  virtual_text = { spacing = 2, prefix = '●', source = 'if_many' },
  float = { source = true, wrap = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.INFO] = '»',
      [vim.diagnostic.severity.HINT] = '⚑',
    },
  },
})

-- Format Go / Python on save (gofmt via gopls, ruff format). Toggle: <leader>af
vim.g.autoformat = true
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.go', '*.py' },
  group = vim.api.nvim_create_augroup('FormatOnSave', { clear = true }),
  callback = function(ev)
    if vim.g.autoformat then
      vim.lsp.buf.format({ async = false, id = ev.buf })
    end
  end,
})

local function on_attach(_, bufnr)
  local function m(lhs, rhs, desc)
    map('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  m('gd', vim.lsp.buf.definition, 'Definition')
  m('gD', vim.lsp.buf.declaration, 'Declaration')
  m('gr', vim.lsp.buf.references, 'References')
  m('gi', vim.lsp.buf.implementation, 'Implementation')
  m('gy', vim.lsp.buf.type_definition, 'Type definition')
  m('K', vim.lsp.buf.hover, 'Hover docs')
  m('<C-k>', vim.lsp.buf.hover, 'Hover docs (reference)')
  m('gl', vim.diagnostic.open_float, 'Line diagnostics')
  m('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
  m(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
  m('<leader>nd', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
  m('<leader>pd', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
  m('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  m('<leader>ca', vim.lsp.buf.code_action, 'Code action')
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
  capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
end)

-- Inlay hints (gopls / ty support them; harmless for servers that don't)
vim.lsp.inlay_hint.enable(true)

vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Go
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = { unusedparams = true },
    },
  },
})

-- Python (ty: Astral's type checker / language server, config via ty.toml / pyproject.toml)
vim.lsp.config('ty', {})

-- Python linting / formatting
vim.lsp.config('ruff', {})

-- Only enable servers that are actually on PATH
for name, cmd in pairs({
  gopls = 'gopls',
  ty = 'ty',
  ruff = 'ruff',
}) do
  if vim.fn.executable(cmd) == 1 then
    vim.lsp.enable(name)
  end
end
