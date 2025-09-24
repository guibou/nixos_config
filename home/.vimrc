lua << EOF
vim.pack.add({
    'https://github.com/ibhagwan/fzf-lua',

    -- LSP
    'https://github.com/neovim/nvim-lspconfig',

    -- Listing of LSP error
    'https://github.com/kyazdani42/nvim-web-devicons',
    'https://github.com/folke/lsp-trouble.nvim',

    -- Misc
    'https://github.com/liuchengxu/vim-which-key',
    'https://github.com/nvim-lualine/lualine.nvim',

    -- Languages
    'https://github.com/LnL7/vim-nix',
    'https://github.com/tikhomirov/vim-glsl',
    'https://github.com/mechatroner/rainbow_csv',

    -- Git
    'https://github.com/lewis6991/gitsigns.nvim',

    -- Theme
    'https://github.com/ryanoasis/vim-devicons',
    'https://github.com/EdenEast/nightfox.nvim',
    'https://github.com/chrisbra/unicode.vim',

    -- illuminate symbols under cursor
    'https://github.com/RRethy/vim-illuminate',

    'https://github.com/guibou/PyF', -- TODO { 'rtp': 'tree-sitter-pyf/vim-plugin/after', }

    'https://github.com/linrongbin16/lsp-progress.nvim',

    --" Images
    -- Clip image directly into neovim
    'https://github.com/HakonHarnes/img-clip.nvim',
    -- Image support and math equation in markdown
    'https://github.com/folke/snacks.nvim',

    'https://github.com/echasnovski/mini.indentscope',
})
EOF

" set completeopt=menuone,noselect
set completeopt=menu,menuone,noselect

set inccommand=nosplit

let mapleader = "\<Space>"
set list

" curly waves in term
set termguicolors
let g:one_allow_italics = 1
let g:onedark_terminal_italics = 1

noremap <Leader><Space> <cmd>FzfLua files<cr>
noremap <Leader>o <cmd>FzfLua oldfiles<cr>
noremap <Leader>b <cmd>FzfLua buffers<cr>
noremap <Leader>/ <cmd>FzfLua live_grep<cr>
noremap <Leader>* <cmd>:lua FzfLua.live_grep({search = vim.fn.expand('<cword>')})<cr>
noremap <Leader>s <cmd>:lua FzfLua.git_diff({ cmd = "jj diff --name-only", previewer = { cmd_modified    = "jj diff --git --no-pager --no-color {file} {ref}"} })<cr>
noremap <Leader>S <cmd>:lua FzfLua.git_diff({ cmd = "jj diff --from 'trunk()' --name-only", previewer = { cmd_modified    = "jj diff --git --no-pager --no-color {file} {ref} --from 'trunk()'"} })<cr>
noremap <Leader>ca <cmd>FzfLua lsp_code_actions previewer=codeaction_native<cr>

noremap <Leader>cD <cmd>FzfLua lsp_incoming_calls<cr>
noremap <Leader>cR <cmd>FzfLua lsp_references<cr>
noremap <Leader>cd <cmd>FzfLua lsp_definitions<cr>

noremap <Leader>ci <cmd>FzfLua lsp_implementations<cr>

noremap <Leader>cl :lua vim.lsp.codelens.run()<cr>
noremap <Leader>cr :lua vim.lsp.buf.rename()<cr>
noremap <Leader>ch :lua vim.lsp.buf.hover { border = "rounded" }<cr>
noremap <Leader>ct <cmd>FzfLua lsp_typedefs<cr>
noremap <Leader>cs <cmd>FzfLua lsp_workspace_symbols<cr>
noremap <Leader>cf :lua vim.lsp.buf.format()<cr>
noremap <Leader>ee :lua vim.diagnostic.open_float { border = "rounded" }<cr>
noremap <Leader>en :lua vim.diagnostic.jump{ count = 1, float= { border = "rounded" }, severity =  vim.diagnostic.severity.ERROR }<cr>
noremap <Leader>eN :lua vim.diagnostic.jump{ count = 1, float= { border = "rounded" } }<cr>
noremap <Leader>ep :lua vim.diagnostic.jump { count = -1, float = {border = "rounded" , severity =  vim.diagnostic.severity.ERROR } }<cr>
noremap <Leader>ep :lua vim.diagnostic.jump { count = -1, float = {border = "rounded" } }<cr>

" Git things
noremap <Leader>gh <cmd>:Gitsigns preview_hunk<cr>
noremap <Leader>gp <cmd>:Gitsigns prev_hunk<cr>
noremap <Leader>gn <cmd>:Gitsigns next_hunk<cr>
noremap <Leader>gU <cmd>:Gitsigns reset_hunk<cr>
noremap <Leader>gs <cmd>:Gitsigns stage_hunk<cr>
noremap <Leader>gtd <cmd>:Gitsigns toggle_deleted<cr>
noremap <Leader>gbo <cmd>:Gitsigns change_base origin/dev<cr>
noremap <Leader>gbh <cmd>:Gitsigns change_base HEAD<cr>

set clipboard=unnamed,unnamedplus
set mouse=a

set spell
set smartcase
set ignorecase

set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" save a file as sudo
cmap w!! $!sudo tee > /dev/null %

set scrolloff=10

set updatetime=100

set signcolumn=yes

lua << EOF
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('pyright')
vim.lsp.enable('ccls')
vim.lsp.enable('julials')

-- local symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
local symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}

vim.diagnostic.config({
  virtual_text = true,
  signs = {
       text = {
         [vim.diagnostic.severity.ERROR] = symbols["error"],
         [vim.diagnostic.severity.WARN] = symbols["warn"],
         [vim.diagnostic.severity.INFO] = symbols["info"],
         [vim.diagnostic.severity.HINT] = symbols["hint"]
       }

      },
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})


blink = require("blink.cmp")
blink.setup({
  completion = {
       documentation = {
            -- Controls whether the documentation window will automatically show when selecting a completion item
            auto_show = true,
        },
    },
    signature = { enabled = true }
})


vim.lsp.enable('asm')
vim.lsp.config('asm', {
    single_file_support = true,
})

vim.lsp.enable('nil_ls')
vim.lsp.config('nil_ls', {
   settings = {
        ['nil'] = {
          formatting = {
            command = { "nixpkgs-fmt" },
          },
        }
   }
})

local default_caps = {
  workspace = {
    didChangeWatchedFiles = {
      -- Disabled because it eats a lot of CPU on linux
      dynamicRegistration = false,
    },
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    -- Inlay hint
    -- Disabled, most of the time, I don't like the result, it does not update
    -- correctly when editing and confuses me.
    -- vim.lsp.inlay_hint.enable(true, { 0 })

    -- Setup color
    vim.lsp.document_color.enable(true, 0, {style = 'virtual'})
  end,
})

vim.lsp.enable('yamlls')
vim.lsp.enable('pyright')
vim.lsp.enable('cssls')

vim.lsp.enable('hls')
vim.lsp.config('hls', {
    single_file_support = true,
    cmd = {
      "haskell-language-server",
      -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.10.1/haskell-language-server-2.10.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
      -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.12.2/haskell-language-server-2.11.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        "--lsp",
        -- "--debug", "--logfile", "/tmp/hls.log"
        -- "+RTS", "--nonmoving-gc", "-RTS"
        -- Run haskell language server memory profiling, every 10s, should not have impact of performance but I'll have a profile after long editing sessions.
        -- "+RTS", "-l", "-hT", "-i5", "-RTS"
    },

    -- https://github.com/neovim/neovim/pull/22405
    capabilities = default_caps,

    settings = {
        haskell = {
            -- checkProject = false,
            -- checkParents = "NeverCheck",

            plugin = {
                 ["hlint"] = {
                     globalOn = false;
                 },
                 ["importLens"] = {
                    inlayHintsOn = true;
                 };
                 ["explicit-fields"] = {
                    inlayHintsOn = false;
                 };
                 ["semanticTokens"] = {
                     globalOn = true;
                 };
            },
        }
    }
})

require('nightfox').setup({
    options = {
        styles = {
            comments = "italic",
        },
    }
})

-- fzflua logic
local fzflua = require'fzf-lua'
fzflua.register_ui_select()
fzflua.setup({
  winopts = {
      preview = {
          layout = "vertical";
      }
  }
})

-- Install PyF parser
-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.pyf = {
--     install_info = {
--         url = "https://github.com/guibou/PyF",
--         files = { "src/parser.c" },
--         -- optional entries:
--         branch = "main", -- default branch in case of git repo if different from master
--         location = "tree-sitter-pyf",
--         generate_requires_npm = false, -- if stand-alone parser without npm dependencies
--     },
-- }

require "nvim-treesitter.configs".setup {
    ensure_install = { "haskell", "json", "vim", "python", "pyf", "lua", "markdown" },
    playground = {
        enable = true
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
    indent = {
        enable = false;
    },
}

require('gitsigns').setup {
    numhl = false,
    signcolumn = true,
    -- linehl = true,
    -- word_diff = true,
    -- current_line_blame = true,
}

statusline = {
  lualine_a = {'mode'},
  lualine_c = {
      -- 'branch',
      {'diagnostics',
      sources = {'nvim_workspace_diagnostic'},
      symbols = symbols}
  },
  lualine_b = {},

  lualine_z = {},
  lualine_y = {},
  lualine_x = {
      function()
        return require('lsp-progress').progress()
      end
  }
}
require('lsp-progress').setup({})

winbar = {
  lualine_b = {{'filetype', icon_only = true}, {
      'filename',
      path=1,
      on_click = function(_nb_of_clicks, _button, _modifiers)
          local filename = vim.fn.getreg('%')
          print('copying filename to clipboard: ' .. filename)
          vim.cmd("call provider#clipboard#Call('set', [ ['" .. filename .. "'], 'v','\"'])")
      end,
      }},
      lualine_c = { },
  lualine_a = {},
  lualine_x = {{
      'diagnostics',
      sources = {'nvim_diagnostic'},
      symbols = symbols}
  },
  lualine_y = {'searchcount'},
  lualine_z = {'progress', 'location'}
}


require('lualine').setup {
  options = {
    global_status = true,
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = statusline,
  sections_inactive = statusline,
  tabline = {},
  winbar = winbar,
  inactive_winbar = winbar,
  extensions = {}
}

-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})

local watchfiles = require('vim.lsp._watchfiles')
local default_watchfunc = watchfiles._watchfunc
watchfiles._watchfunc = function(path, opts, callback)
  if path == "/home/guillaume" or path == "/nix/store" or path == "/nix" or path == "/"
  then
      vim.api.nvim_echo({{"ignored watch_file: ".. path}}, true, {})
      return function()
        vim.api.nvim_echo({{"ignored watch_file_end:"..path}}, true, {})
      end
  else
    return default_watchfunc(path, opts, callback)
  end
end

-- require("image").setup({
--   backend = "kitty",
--   integrations = {
--     markdown = {
--       enabled = true,
--       clear_in_insert_mode = false,
--       download_remote_images = true,
--       only_render_image_at_cursor = false,
--       filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
--     }
--   }
-- })

require("snacks").setup({
image = {
    conceal = true;
}
})

require('mini.indentscope').setup(
{
    symbol = "▎",
    draw = {
        animation = require('mini.indentscope').gen_animation.none(),
    };
    options = {
        border = "none",
    },
})

-- autoformat on save
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    -- Only enabling format on save for some directories
    jinko = "/home/guillaume/jinko/jinko/"
    if string.sub(args.file, 0, string.len(jinko)) == jinko
    then
    else
      print("format on save disabled for " .. args.file)
      return
    end


    -- 2
    vim.api.nvim_create_autocmd("BufWritePre", {
      -- 3
      buffer = args.buf,
      callback = function()
        -- 4 + 5
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})


-- Override diagnostics in HLS
local haskell_diagnostic_severity = {
      -- No type signature at top level
      ["GHC-38417"] = vim.diagnostic.severity.HINT,
      -- Defined but not used
      ["GHC-40910"] = vim.diagnostic.severity.HINT,
      -- Defaulting
      ["GHC-18042"] = vim.diagnostic.severity.HINT,
      -- Warnings and deprecated
      ["GHC-63394"] = vim.diagnostic.severity.INFO,
      -- Deprecated
      ["GHC-68441"] = vim.diagnostic.severity.INFO,
     }

-- Save the original handler
local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  if result and result.diagnostics then
    for _, diag in ipairs(result.diagnostics) do
      new_severity = haskell_diagnostic_severity[diag.code]
      if new_severity ~= nil
      then
        diag.severity = new_severity
      end
    end
  end
  -- Pass to original handler
  orig_handler(err, result, ctx, config)
end

vim.api.nvim_create_autocmd("LspTokenUpdate", {
  callback = function(args)
    local token = args.data.token
    if token.type == "variable" then
      vim.lsp.semantic_tokens.highlight_token(
        token, args.buf, args.data.client_id, "@lsp.type.variable", {priority = 200})
    end
  end,
})


-- local actions = require "telescope.actions"
-- local action_state = require "telescope.actions.state"
-- local function change_gitsign_base(prompt_bufnr, map)
--   actions.select_default:replace(function()
--     actions.close(prompt_bufnr)
--     local selection = action_state.get_selected_entry()
--     vim.cmd{ cmd = "Gitsigns", args = {"change_base", '"' .. selection.value .. '"'}}
--   end)
--   return true
-- end
-- 
-- gitsign_change_base_using_jj = function()
--   local opts = {
--     git_command={"jj","log","--no-graph","--template","telescope", "-r", "trunk()::@"},
--     attach_mappings = change_gitsign_base
--   }
--   require("telescope.builtin").git_commits(opts)
-- end


-- Change colorscheme when receiving signal
vim.api.nvim_create_autocmd({"Signal"}, {
     callback = function()
       vim.schedule(load_theme_from_os_preferences)
	end
})

EOF
noremap <Leader>gb <cmd>lua gitsign_change_base_using_jj()<cr>
noremap <Leader>ei <cmd>FzfLua lsp_workspace_diagnostics<cr>
noremap <Leader>ew <cmd>FzfLua lsp_workspace_diagnostics severity_limit=2<cr>
noremap <Leader>ee <cmd>FzfLua lsp_workspace_diagnostics severity_limit=1<cr>

" Folding: I don't like it
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

" Setup which key
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

" Allow file change
set hidden

set list listchars=tab:\ \ ▸,trail:·,precedes:←,extends:→,nbsp:␣

" break at word boundaries
set linebreak
autocmd BufEnter *.hs setlocal shiftwidth=2

let g:mkdp_browser='firefox'

" Lenses updates
" I'm not fan of code lens. In haskell, it does not bring much benefit and is
" replaced by inlay hint on most use case I like.
" autocmd BufEnter,InsertLeave *.hs lua vim.lsp.codelens.refresh({ bufnr = 0})

tnoremap <Esc> <C-\><C-n>

set nu relativenumber

"sign define DiagnosticSignError text= linehl= texthl=DiagnosticSignError numhl=
"sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl=
"sign define DiagnosticSignInfo text= linehl= texthl=DiagnosticSignInfo numhl=
"sign define DiagnosticSignHint text= linehl= texthl=DiagnosticSignHint numhl=

" No status line
" I would like to disable it entirely, but looks like it is not possible
set laststatus=3
set cmdheight=0

" TODO: tune the winbar so filename change color relative to the mode
" set winbar=%!WinBar()

" Actually, numbers are taking too much place
set nonu
set norelativenumber

" This way I can have signs and git line
set signcolumn=yes:2

" Some quick shortcut to file I care about
noremap <Leader>qv <cmd>:e ~/nixos_config/home/.vimrc<cr>
noremap <Leader>qh <cmd>:e ~/nixos_config/home.nix<cr>

"s Nice diff with commont parts in lines
set diffopt+=linematch:50

