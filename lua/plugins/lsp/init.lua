--[[
================================================================================
LANGUAGE SERVER PROTOCOL (LSP) CONFIGURATION
================================================================================
This file configures Language Server Protocol support for Neovim, providing:
- Intelligent code completion
- Go-to-definition and references
- Real-time error checking and diagnostics
- Code actions and refactoring
- Hover documentation
- Symbol search and navigation

Language servers configured:
1. Pyright - Python language server
2. ts_ls - TypeScript/JavaScript language server  
3. lua_ls - Lua language server (for Neovim config editing)

Dependencies:
- Mason: LSP server installer and manager
- mason-lspconfig: Bridge between Mason and lspconfig
- cmp-nvim-lsp: Integration with completion engine
================================================================================
--]]

return {
  -- ============================================================================
  -- NVIM-LSPCONFIG - MAIN LSP CONFIGURATION
  -- ============================================================================
  -- The core plugin that configures and manages language servers
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },  -- Load when opening files
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",        -- LSP completion source
      "williamboman/mason.nvim",      -- LSP server manager
      "williamboman/mason-lspconfig.nvim",  -- Mason-lspconfig bridge
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      
      -- ======================================================================
      -- LSP CAPABILITIES SETUP
      -- ======================================================================
      -- Enhanced capabilities for better integration with completion engine
      local capabilities = cmp_nvim_lsp.default_capabilities()
      
      -- Add additional capabilities if needed
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" }
      }
      
      -- ======================================================================
      -- PYTHON LSP CONFIGURATION (PYRIGHT)
      -- ======================================================================
      -- Pyright is Microsoft's Python language server with excellent type checking
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,        -- Automatically search for Python paths
              diagnosticMode = "workspace",  -- Check entire workspace, not just open files
              useLibraryCodeForTypes = true, -- Use library code for better type inference
              typeCheckingMode = "basic",    -- Basic type checking (can be "strict" or "off")
            },
          },
        },
        -- Custom initialization to handle virtual environments
        on_init = function(client)
          -- Try to detect and use the current virtual environment
          local venv_path = os.getenv("VIRTUAL_ENV")
          if venv_path then
            client.config.settings.python.pythonPath = venv_path .. "/bin/python"
          end
        end,
      })
      
      -- ======================================================================
      -- TYPESCRIPT/JAVASCRIPT LSP CONFIGURATION (TS_LS)
      -- ======================================================================
      -- ts_ls is the official TypeScript language server (replaces deprecated tsserver)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
      
      -- ======================================================================
      -- LUA LSP CONFIGURATION (LUA_LS)
      -- ======================================================================
      -- Lua language server for editing Neovim configuration files
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",  -- Use LuaJIT (Neovim's Lua runtime)
            },
            diagnostics = {
              globals = { "vim" },  -- Recognize 'vim' as a global variable
            },
            workspace = {
              -- Add Neovim runtime files to workspace
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,  -- Don't ask about third-party libraries
            },
            telemetry = {
              enable = false,  -- Disable telemetry
            },
            hint = {
              enable = true,  -- Enable inlay hints
            },
          },
        },
      })
      
      -- ======================================================================
      -- GLOBAL LSP KEY MAPPINGS
      -- ======================================================================
      -- These mappings work across all buffers and provide access to LSP diagnostics
      
      -- Diagnostic navigation and display
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { 
        desc = "Show diagnostic in floating window" 
      })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { 
        desc = "Go to previous diagnostic" 
      })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { 
        desc = "Go to next diagnostic" 
      })
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { 
        desc = "Add diagnostics to location list" 
      })
      
      -- ======================================================================
      -- BUFFER-SPECIFIC LSP KEY MAPPINGS
      -- ======================================================================
      -- These mappings are only available when an LSP server is attached to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
          
          -- Buffer local mappings for LSP functionality
          local opts = { buffer = ev.buf }
          
          -- Navigation mappings
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, 
            vim.tbl_extend('force', opts, { desc = "Go to declaration" }))
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
            vim.tbl_extend('force', opts, { desc = "Go to definition" }))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, 
            vim.tbl_extend('force', opts, { desc = "Go to implementation" }))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, 
            vim.tbl_extend('force', opts, { desc = "Show references" }))
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, 
            vim.tbl_extend('force', opts, { desc = "Go to type definition" }))
          
          -- Documentation and help
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, 
            vim.tbl_extend('force', opts, { desc = "Show hover documentation" }))
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, 
            vim.tbl_extend('force', opts, { desc = "Show signature help" }))
          
          -- Workspace management
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, 
            vim.tbl_extend('force', opts, { desc = "Add workspace folder" }))
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, 
            vim.tbl_extend('force', opts, { desc = "Remove workspace folder" }))
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, vim.tbl_extend('force', opts, { desc = "List workspace folders" }))
          
          -- Code actions and refactoring
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, 
            vim.tbl_extend('force', opts, { desc = "Rename symbol" }))
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, 
            vim.tbl_extend('force', opts, { desc = "Show code actions" }))
          
          -- Formatting
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, vim.tbl_extend('force', opts, { desc = "Format buffer" }))
        end,
      })
      
      -- ======================================================================
      -- LSP UI CUSTOMIZATION
      -- ======================================================================
      -- Customize how LSP diagnostics and messages are displayed
      
      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',  -- Could be '■', '▎', 'x', '●'
          source = "if_many",  -- Show source if multiple sources
        },
        signs = true,          -- Show signs in sign column
        underline = true,      -- Underline problematic text
        update_in_insert = false,  -- Don't update diagnostics in insert mode
        severity_sort = true,  -- Sort diagnostics by severity
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
      
      -- Customize LSP handlers for better UI
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
        }
      )
      
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = "rounded",
        }
      )
    end,
  },
  
  -- ============================================================================
  -- MASON - LSP SERVER MANAGER
  -- ============================================================================
  -- Mason provides a user-friendly way to install and manage LSP servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",  -- Load when :Mason command is used
    keys = { 
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Open Mason (LSP manager)" } 
    },
    build = ":MasonUpdate",  -- Update Mason when plugin is updated
    opts = {
      -- Automatically install these tools when Mason starts
      ensure_installed = {
        "pyright",                    -- Python LSP
        "typescript-language-server", -- TypeScript/JavaScript LSP
        "lua-language-server",        -- Lua LSP
        -- Add more tools as needed:
        -- "black",                   -- Python formatter
        -- "isort",                   -- Python import sorter
        -- "prettier",                -- JavaScript/TypeScript formatter
        -- "eslint_d",                -- JavaScript/TypeScript linter
      },
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      
      -- Auto-install tools when Mason registry is ready
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Trigger FileType event to possibly load newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      
      -- Function to ensure tools are installed
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      
      -- Install tools when Mason is ready
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  
  -- ============================================================================
  -- MASON-LSPCONFIG - BRIDGE BETWEEN MASON AND LSPCONFIG
  -- ============================================================================
  -- Automatically configures LSP servers installed by Mason
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      -- Ensure these LSP servers are installed
      ensure_installed = {
        "pyright",     -- Python
        "ts_ls",       -- TypeScript/JavaScript
        "lua_ls",      -- Lua
      },
      -- Automatically setup LSP servers installed by Mason
      automatic_installation = true,
    },
  },
}

--[[
================================================================================
LSP USAGE GUIDE
================================================================================

KEY MAPPINGS:
Navigation:
- gd: Go to definition
- gD: Go to declaration  
- gi: Go to implementation
- gr: Show references
- <space>D: Go to type definition

Documentation:
- K: Show hover documentation
- <C-k>: Show signature help

Diagnostics:
- <space>e: Show diagnostic in floating window
- [d: Go to previous diagnostic
- ]d: Go to next diagnostic
- <space>q: Add diagnostics to location list

Code Actions:
- <space>ca: Show code actions
- <space>rn: Rename symbol
- <space>f: Format buffer

Workspace:
- <space>wa: Add workspace folder
- <space>wr: Remove workspace folder
- <space>wl: List workspace folders

COMMANDS:
- :Mason - Open Mason UI to manage LSP servers
- :LspInfo - Show LSP server information
- :LspRestart - Restart LSP servers
- :LspLog - Show LSP logs

SETUP NOTES:
1. LSP servers are automatically installed via Mason
2. Configuration is applied when you open supported file types
3. Virtual environments are automatically detected for Python
4. All language servers include completion, diagnostics, and navigation

================================================================================
--]]
