" Install vim-plug
source ~/.local/share/nvim/site/autoload/plug.vim
call plug#begin('~/.vim/plugged')

" fuzzy
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Does not build anymore
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'

Plug 'junegunn/fzf'
" Plug 'monkoose/fzf-hoogle.vim'
Plug 'junegunn/fzf.vim'

" LSP
Plug 'neovim/nvim-lspconfig'

" Some nicer UIs for lsp, such as call graph and peek
Plug 'glepnir/lspsaga.nvim'

" Listing of LSP error
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/lsp-trouble.nvim' " , {'branch': 'dev'}

" Misc
Plug 'liuchengxu/vim-which-key'
Plug 'nvim-lualine/lualine.nvim'
"
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'direnv/direnv.vim'
Plug 'lukas-reineke/indent-blankline.nvim'

" Languages
Plug 'LnL7/vim-nix'
Plug 'tikhomirov/vim-glsl'
Plug 'mechatroner/rainbow_csv'

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'

" Theme
Plug 'ryanoasis/vim-devicons'
Plug 'EdenEast/nightfox.nvim'
Plug 'chrisbra/unicode.vim'

" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" illuminate symbols under cursor
Plug 'RRethy/vim-illuminate'

Plug 'guibou/PyF', { 'rtp': 'tree-sitter-pyf/vim-plugin/after' }

Plug 'lambdalisue/suda.vim'

Plug 'arkav/lualine-lsp-progress'

" Register menu help
Plug 'tversteeg/registers.nvim'


" Clip image directry into neovim
Plug 'HakonHarnes/img-clip.nvim'

call plug#end()

" set completeopt=menuone,noselect
set completeopt=menu,menuone,noselect

set inccommand=nosplit

let mapleader = "\<Space>"
set list

" curly waves in term
set termguicolors
let g:one_allow_italics = 1
let g:onedark_terminal_italics = 1

" Git Grep
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

noremap <Leader><Space> <cmd>Telescope git_files<cr>
noremap <Leader>o <cmd>Telescope oldfiles<cr>
noremap <Leader>b <cmd>Telescope buffers show_all_buffers=true<cr>
" noremap <Leader>/ <cmd>lua require("telescope").extensions.live_grep_args.live_grep_args({default_text = vim.fn.expand('<cword>')})<cr>
noremap <Leader>/ <cmd>lua require("telescope").extensions.live_grep_args.live_grep_args({vimgrep_arguments = { "rg", "--hidden", "--smart-case", "--vimgrep", "--max-filesize", "1000000"} })<cr>
" noremap <Leader>* <cmd>Telescope grep_string<cr>
noremap <Leader>* <cmd>lua require("telescope").extensions.live_grep_args.live_grep_args({vimgrep_arguments = { "rg", "--hidden", "--smart-case", "--vimgrep", "--max-filesize", "1000000"},  default_text = vim.fn.expand('<cword>')})<cr>
noremap <Leader>f <cmd>Telescope find_files<cr>
noremap <Leader>s <cmd>Telescope git_status<cr>
noremap <Leader>ca <cmd>lua vim.lsp.buf.code_action()<cr>
noremap <Leader>C <cmd>Telescope colorscheme enable_preview=true<cr>

noremap <Leader>cD <cmd>Telescope lsp_references<cr>

noremap <Leader>cd <cmd>Telescope lsp_definitions<cr>
noremap <Leader>cl :lua vim.lsp.codelens.run()<cr>
noremap <Leader>cr :Lspsaga rename<cr>
noremap <Leader>ch :lua vim.lsp.buf.hover()<cr>
noremap <Leader>ch :Lspsaga hover_doc<cr>
noremap <Leader>ct <cmd>Telescope lsp_type_definitions<cr>
noremap <Leader>cs <cmd>Telescope lsp_dynamic_workspace_symbols<cr>
" noremap <Leader>ct :TroubleToggle<cr>
" noremap <Leader>cT :Trouble lsp_references<cr>
noremap <Leader>cf :lua vim.lsp.buf.format()<cr>
noremap <Leader>ee :lua vim.diagnostic.open_float()<cr>
noremap <Leader>en :lua vim.diagnostic.goto_next()<cr>
noremap <Leader>ep :lua vim.diagnostic.goto_prev()<cr>

" Git things
noremap <Leader>gh <cmd>:Gitsigns preview_hunk<cr>
noremap <Leader>gp <cmd>:Gitsigns prev_hunk<cr>
noremap <Leader>gn <cmd>:Gitsigns next_hunk<cr>
noremap <Leader>gU <cmd>:Gitsigns reset_hunk<cr>
noremap <Leader>gs <cmd>:Gitsigns stage_hunk<cr>

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
local lspconfig = require 'lspconfig'

lspconfig.rust_analyzer.setup {}
lspconfig.pyright.setup {}
lspconfig.ccls.setup {}

-- Setup lspconfig.

-- local symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
local symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}

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


lspconfig.nil_ls.setup{
   settings = {
        ['nil'] = {
          formatting = {
            command = { "nixpkgs-fmt" },
          },
        }
   }
}

local default_caps = {
  workspace = {
    didChangeWatchedFiles = {
      -- fast update
      dynamicRegistration = true,
    },
  },
}
lspconfig.yamlls.setup {}
lspconfig.hls.setup({
    single_file_support = true,
    cmd = {
        "haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.6.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.6.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.5.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.4.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.6.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
       -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.5.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        --"/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.5.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.4.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        -- "/home/guillaume/srcs/haskell-language-server/dist-newstyle/build/x86_64-linux/ghc-9.6.4/haskell-language-server-2.4.0.0/x/haskell-language-server/build/haskell-language-server/haskell-language-server",
        "--lsp",
        -- "--debug", "--logfile", "/tmp/hls.log"
        -- "+RTS", "--nonmoving-gc", "-RTS"
    },

    -- https://github.com/neovim/neovim/pull/22405
    capabilities = default_caps,

    -- root_dir = lspconfig.util.root_pattern(
    --     "*.cabal",
    --     "stack.yaml",
    --     "cabal.project",
    --     -- , "package.yaml"
    --     "hie.yaml"
    -- ),

    settings = {
        haskell = {
            -- completionSnippetsOn = true,
            checkProject = true,
            -- checkParents = "NeverCheck",

            plugin = {
                 -- Used to disable the snippet
                 ["ghcide-completions"] = {
                     config = {
                         ---snippetsOn = false;
                     }
                 },
                 ["hlint"] = {
                     diagnosticsOn = false;
                 },
            },
            -- I don't know what this thing is, but hey, maybe a good thing
            -- flags = {
            --     allow_incremental_sync = false;
            -- }
        }
    }
})

local filetypes = {
  "gitcommit",
  "markdown",
  "plaintex",
  "rst",
  "tex",
  "rust",
  "python",
  "html",
  "haskell",
}

-- lspconfig.ltex.setup(
-- {
--     filetypes = filetypes,
--     settings = {
--         ltex = {
--             -- enabled = filetypes, 
--             additionalRules = {
--                 languageModel = "~/ngrams/",
--                 checkFrequency = "edit",
--                 motherTongue = "fr_FR",
--             },
-- 
-- 
-- 
-- 
--             -- disabledRules = {
--             --   en_US = ["MORFOLOGIK_RULE"]
--             -- }
--         }
--     }
-- })

local cmp = require 'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<C-n>'] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end
        }),
        ['<C-p>'] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end
        }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        --  { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 blend=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B blend=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 blend=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 blend=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF blend=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD blend=nocombine]]
end)

require("ibl").setup {
    indent = {
        char = "▏",
        highlight = 
        {
           "IndentBlanklineIndent1",
           "IndentBlanklineIndent2",
           "IndentBlanklineIndent3",
           "IndentBlanklineIndent4",
           "IndentBlanklineIndent5",
           "IndentBlanklineIndent6",
        }
    },
    exclude = { buftypes = { "terminal", "help", "vim-plug", "nofile" }},
}

require('nightfox').setup({
    options = {
        styles = {
            comments = "italic",
        },
    },
    groups = {
        -- LspCodeLens = { fg = "${cyan}", style = "italic"},
    }
})

-- require('neogit').setup {}
require("trouble").setup {}
-- require("neoclip").setup()

local trouble_source_telescope = require("trouble.sources.telescope")
require("telescope").setup {
    defaults = {
        layout_strategy = 'vertical',
        i = { ["<c-t>"] = trouble_source_telescope.open },
        n = { ["<c-t>"] = trouble_source_telescope.open },
    },
    extensions = {
        live_grep_args = {
            auto_quoting = false
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
        }
    }
}
require('telescope').load_extension('ui-select')
require('telescope').load_extension('fzf')

-- Install PyF parser
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.pyf = {
    install_info = {
        url = "https://github.com/guibou/PyF",
        files = { "src/parser.c" },
        -- optional entries:
        branch = "main", -- default branch in case of git repo if different from master
        location = "tree-sitter-pyf",
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    },
}

require "nvim-treesitter.configs".setup {
    ensure_install = { "haskell", "json", "vim", "python", "pyf", "lua" },
    playground = {
        enable = true
    },
    --  haskell = {
    --   enable = true
    --    }
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
    indent = {
        enable = false;
    },

    -- Allow to extend selection with v/V
    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = "v",
        node_decremental = "V",
      },
    },
}
-- require('hologram').setup{ auto_display = true }

require('gitsigns').setup {
    numhl = false,
    signcolumn = true,
    -- linehl = true,
    -- word_diff = true,
    -- current_line_blame = true,
}

require("lspsaga").setup({
  lightbulb = {
    enable = false;
  },
  symbol_in_winbar = {
    enable = false;
    respect_root = false;
    show_file = false;
  },
  diagnostic = {
    on_insert_follow = false;
    on_insert = false;
  }
})


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
  sections = {
    lualine_a = {'mode'},
    lualine_c = {{
        'branch',
        {'diagnostics',
        sources = {'nvim_diagnostic'},
        always_visible = true,
        symbols = symbols}
    }
    },
    lualine_b = {},

    lualine_z = {},
    lualine_y = {},
    lualine_x = {
        {'lsp_progress',
           display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } }
        },
        'searchcount'
    }
  },
  sections_inactive = {
    lualine_a = {'mode'},
    lualine_c = {{
        'branch',
        {'diagnostics',
        sources = {'nvim_workspace_diagnostic'},
        always_visible = true,
        symbols = symbols}
    }
    },
    lualine_b = {},

    lualine_z = {},
    lualine_y = {},
    lualine_x = {
        {'lsp_progress',
           display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } }
        },
        'searchcount'
    }
  },
  tabline = {},
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
    lualine_c = {
    { function() return require('lspsaga.symbolwinbar'):get_winbar() end }
        },
    lualine_a = {},
    lualine_x = {{
        'diagnostics',
        sources = {'nvim_diagnostic'},
        symbols = symbols}
    },
    --lualine_x = {'encoding', 'fileformat', 'filetype'},
    --lualine_y = {'progress'},
    lualine_z = {},
    lualine_y = {'location'}
  },
  inactive_winbar = {
    lualine_b = {{'filetype', icon_only = true}, {'filename', path = 1}},
    lualine_c = {
    { function() return require('lspsaga.symbolwinbar'):get_winbar() end }
        },
    lualine_a = {},
    lualine_x = {{
        'diagnostics',
        sources = {'nvim_diagnostic'},
        symbols = symbols}
    },
    --lualine_x = {'encoding', 'fileformat', 'filetype'},
    --lualine_y = {'progress'},
    lualine_z = {},
    lualine_y = {'location'}
      },
  extensions = {}
}

require("registers").setup()

-- Completly dummy watchfile
local watchfiles = require('vim.lsp._watchfiles')
local default_watchfunc = watchfiles._watchfunc
watchfiles._watchfunc = function(path, opts, callback)
  if path == "/home/guillaume"
  then
      vim.api.nvim_echo({{"ignored watch_file: ".. path}}, true, {})
      return function()
        vim.api.nvim_echo({{"ignored watch_file_end:"..path}}, true, {})
      end
  else
    return default_watchfunc(path, opts, callback)
  end
end

EOF

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

set omnifunc=v:lua.vim.lsp.omnifunc

let g:mkdp_browser='chromium'

" Lenses updates
autocmd BufEnter,CursorHold,InsertLeave *.hs lua vim.lsp.codelens.refresh({ bufnr = 0})

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

set formatexpr=

"s Nice diff with commont parts in lines
set diffopt+=linematch:50
