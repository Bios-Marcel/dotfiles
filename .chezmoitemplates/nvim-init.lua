---------------------------------------
-- Util
---------------------------------------

local is_linux = vim.uv.os_uname().sysname == 'Linux'
-- If both linux and windows are true, it is WSL
local is_windows = vim.uv.os_gethostname():match(".+-win", 1) ~= nil and not is_linux


---------------------------------------
-- Util end
---------------------------------------

---------------------------------------
-- Editing
---------------------------------------

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.syntax = 'on'

-- Improve scrolling speed
vim.opt.ttyfast = true
vim.opt.mouse = 'a'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 2

-- Sets how neovim will display certain whitespace in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Line numbers
vim.opt.number = true
vim.opt.cursorline = true
vim.wo.relativenumber = true
-- Line numbers in file explorer
vim.g.netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
vim.g.netrw_keepj = "";

-- Swap the split directions, so that the focus feels more natural
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Visualise 80 and 120 character limit
vim.opt.colorcolumn = '+1,+41'
vim.opt.textwidth = 80
vim.opt.formatoptions:remove { "t" }

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Specify leader key (Space)
vim.g.mapleader = " "

-- Save undo history
vim.opt.undofile = true

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

if is_windows then
  -- Seems to be a bug, I've created an issue:
  -- https://github.com/neovim/neovim/issues/26006
  vim.cmd("language en_US")
end

-- Yank to system clipboard; This increases startup time a lot in WSL.
-- vim.opt.clipboard = 'unnamedplus'

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch", -- Highlight group
      timeout = 200,         -- Duration in milliseconds
    })
  end,
})

---------------------------------------
-- Editing end
---------------------------------------

---------------------------------------
-- Plugin manager
---------------------------------------

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

---------------------------------------
-- Plugin manager end
---------------------------------------

---------------------------------------
-- Plugins
---------------------------------------

require('lazy').setup({
  -- Theme
  { 'catppuccin/nvim' },

  -- Jump to character
  {
    'smoka7/hop.nvim',
    version = "*",
    lazy = true,
    config = function()
      require('hop').setup()
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth' },

  -- Debugger
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
    },
  },

  -- Debugger Adapter for Golang
  { 'leoluz/nvim-dap-go' },
  -- Debugger UI
  { 'rcarriga/nvim-dap-ui' },

  -- Highlight selected word in visual space, not the whole file.
  {
    'tzachar/local-highlight.nvim',
    opts = {
      animate = {
        enabled = false,
      },
    },
  },

  -- Make working on the Neovim config doable.
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  -- optional `vim.uv` typings
  { "Bilal2453/luvit-meta", lazy = true },

  {
    'j-hui/fidget.nvim',
    opts = {},
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
    dependencies = {
      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
    },
    lazy = true,
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',

      -- C reimplementation of fzf core algorithm. This is built by nvim.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = function()
          if vim.fn.executable 'cmake' then
            return
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
          end

          return 'make'
        end,
        cond = function()
          return vim.fn.executable 'make' == 1 or vim.fn.executable 'cmake' == 1
        end,
      },
    },
  },

  { 'nvim-telescope/telescope-live-grep-args.nvim' },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
})

-- We only bind this to normal mode for now, as I don't want to affect
-- actions such as delete.
vim.keymap.set('n', 'f', function()
  local hop = require('hop')
  local directions = require('hop.hint').HintDirection

  hop.hint_char1({ direction = directions.AFTER_CURSOR })
end, { remap = true })
vim.keymap.set('n', 'F', function()
  local hop = require('hop')
  local directions = require('hop.hint').HintDirection

  hop.hint_char1({ direction = directions.BEFORE_CURSOR })
end, { remap = true })
vim.keymap.set('n', 't', function()
  local hop = require('hop')
  local directions = require('hop.hint').HintDirection

  hop.hint_char1({ direction = directions.AFTER_CURSOR, hint_offset = -1 })
end, { remap = true })
vim.keymap.set('n', 'T', function()
  local hop = require('hop')
  local directions = require('hop.hint').HintDirection

  hop.hint_char1({ direction = directions.BEFORE_CURSOR, hint_offset = 1 })
end, { remap = true })

---------------------------------------
-- Plugins end
---------------------------------------

require('local-highlight').setup({
  hlgroup = 'Search',
  cw_hlgroup = nil,
  -- Whether to display highlights in INSERT mode or not
  insert_mode = false,
})

---------------------------------------
-- Debugger
---------------------------------------

require("dapui").setup()
require('dap-go').setup {
  -- Additional dap configurations can be added.
  -- dap_configurations accepts a list of tables where each entry
  -- represents a dap configuration. For more details do:
  -- :help dap-configuration
  dap_configurations = {
    {
      -- Must be "go" or it will be ignored by the plugin
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
    {
      type = 'go',
      name = 'Debug launch',
      request = 'launch',
      showLog = false,
      program = "${file}",
      dlvToolPath = vim.fn.exepath('dlv') -- Adjust to where delve is installed
    },
  },
  -- delve configurations
  delve = {
    -- the path to the executable dlv which will be used for debugging.
    -- by default, this is the "dlv" executable on your PATH.
    path = "dlv",
    -- time to wait for delve to initialize the debug session.
    -- default to 20 seconds
    initialize_timeout_sec = 20,
    -- a string that defines the port to start delve debugger.
    -- default to string "${port}" which instructs nvim-dap
    -- to start the process in a random available port
    port = "${port}",
    -- additional args to pass to dlv
    args = {},
    -- the build flags that are passed to delve.
    -- defaults to empty string, but can be used to provide flags
    -- such as "-tags=unit" to make sure the test suite is
    -- compiled during debugging, for example.
    -- passing build flags using args is ineffective, as those are
    -- ignored by delve in dap mode.
    build_flags = "",
  },
}

vim.keymap.set('n', '<F4>', require("dapui").toggle)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F6>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F7>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F8>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp',
  function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      vertical = {
        preview_cutoff = 10,
      },
    },
    preview = {
      filesize_limit = 0.5, --0.5 MB
    },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local find_files = function()
  require('telescope.builtin').find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', '--hidden', '-g', '!.git' } })
end

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require("telescope").extensions.live_grep_args.live_grep_args,
  { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  ---@diagnostic disable-next-line: missing-fields
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'go', 'lua', 'rust', 'tsx', 'html', 'css', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = {
      enable = true,
      disable = function(_, buf)
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-s>',
        scope_incremental = '<c-s>',
        node_decremental = '<c-a>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local lsp_attach = function(bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature Documentation' })

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

---------------------------------------
-- LSP Schtuff
---------------------------------------

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
--  https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- local servers = {
--   marksman = {},
-- }
--
-- if vim.fn.executable "odin" == 1 then
--   servers.ols = {}
-- end
--
-- if vim.fn.executable "cargo" == 1 then
--   servers.rust_analyzer = {}
-- end
--
-- if vim.fn.executable "zig" == 1 then
--   servers.zls = {}
-- end
--
-- if vim.fn.executable "java" == 1 then
--   servers.jdtls = {}
--   servers.kotlin_language_server = {}
-- end

vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          -- Prevent requiring luasnip as a dependency for nvim-cmp
          snippetSupport = false
        },
      },
    },
  },
})

vim.lsp.config.ts = {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  single_file_support = true,
}
vim.lsp.enable('ts')

vim.lsp.config.lua = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      telemetry = { enable = false },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
}
vim.lsp.enable('lua')

vim.lsp.config.templ = {
  cmd = { 'templ', 'lsp' },
  root_markers = { 'go.mod' },
  filetypes = { 'templ' },
}
vim.lsp.enable('templ')

vim.lsp.config.gopls = {
  cmd = { 'gopls', 'serve' },
  root_markers = { 'go.mod' },
  filetypes = { 'go' },
  settings = {
    directory_filters = { "-.git" },
    gofumpt = true,
  },
}
vim.lsp.enable('gopls')

-- if is_windows then
--   servers.powershell_es = {}
-- end
--
-- if vim.fn.executable "node" == 1 then
--   servers.cssls = {}
--   servers.ts_ls = {}
--   servers.html = {}
-- end

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})

---------------------------------------
-- Autocomplete
---------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    lsp_attach(ev.buf)
    -- FIXME nvim-cmp loswerden.
    -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- if client:supports_method('textDocument/completion') then
    --   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    -- end
  end,
})

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'

---@diagnostic disable-next-line: missing-fields
cmp.setup {
  completion = {
    completeopt = 'noinsert',
    autocomplete = {
      cmp.TriggerEvent.TextChanged,
      -- By default, reentering insert mode doesn't open the autocomplete, which
      -- is super annoying.
      cmp.TriggerEvent.InsertEnter,
    },
    keyword_length = 0,
  },
  view       = {
    docs = {
      -- This does work, but not if the given symbol isn't imported yet.
      -- For example in a go file `os.` will not show docs, if `os` isn't import
      -- at the time of autocompleting.
      auto_open = true,
    },
  },
  mapping    = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- Broken on windows, C-l as alternative
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<C-l>'] = cmp.mapping.complete({}),
    ['<Enter>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  -- Required, so we actually select the first item according to our sorting
  -- options and not according to alphabetical order.
  preselect  = cmp.PreselectMode.None,
  sorting    = {
    priority_weight = 1.0,
    comparators = {
      cmp.config.compare.locality,
      cmp.config.compare.order,
    },
  },
  sources    = {
    { name = 'nvim_lsp' },
    -- FIXME Snippets are cool, but I don't care for now.
    -- Even though we don't use snippets, we still need to specify a snippet
    -- engine, since cmp shits itself otherwise.
    -- { name = 'luasnip' },
  },
}

vim.cmd("colorscheme catppuccin-macchiato")

local golang_organize_imports = function(bufnr, isPreflight)
  local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding(bufnr))
  params.context = { only = { "source.organizeImports" } }

  if isPreflight then
    vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function() end)
    return
  end

  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding(bufnr))
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspActionsOnWrite", {}),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat", {}),
      callback = function()
        vim.lsp.buf.format()
      end,
    })

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- The go language server does not organise imports on format.
    if client.name == "gopls" then
      local bufnr = args.buf
      -- hack: Preflight async request to gopls, which can prevent blocking when save buffer on first time opened
      golang_organize_imports(bufnr, true)

      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup("LspGolangOrganizeImports" .. bufnr, {}),
        callback = function()
          golang_organize_imports(bufnr)
        end,
      })
    end
  end,
})

---
--- Macros
---

-- FIXME Conditional only for go files.
vim.keymap.set('n', '<leader>er', function()
  vim.api.nvim_input('oif err != nil {<cr><tab>return err<cr>}<esc>b')
end)

---
--- Shaky stuff we do last, so we can load as much as possible.
---

-- Enable telescope fzf native, if installed
-- But on windows it does not work for now, unsure why.
-- if is_linux then
--   require('telescope').load_extension('fzf')
-- end
