--[[
================================================================================
CODE COMPLETION CONFIGURATION
================================================================================
This file configures nvim-cmp, a powerful completion engine for Neovim that
provides intelligent code completion from multiple sources:

1. LSP servers (language-specific completions)
2. Buffer content (words from open buffers)
3. File paths (for file/directory completion)
4. Snippets (code templates and boilerplate)
5. Neovim Lua API (for config editing)
6. Command line (for Neovim commands)

The completion system integrates with:
- Language servers for context-aware suggestions
- LuaSnip for expandable code snippets
- Friendly-snippets for pre-made snippet collection
================================================================================
--]]

return {
  -- ============================================================================
  -- NVIM-CMP - MAIN COMPLETION ENGINE
  -- ============================================================================
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },  -- Load when entering insert mode or command line
    dependencies = {
      -- ========================================================================
      -- COMPLETION SOURCES
      -- ========================================================================
      "hrsh7th/cmp-nvim-lsp",     -- LSP completion source (most important)
      "hrsh7th/cmp-buffer",       -- Buffer words completion
      "hrsh7th/cmp-path",         -- File path completion
      "hrsh7th/cmp-cmdline",      -- Command line completion
      "hrsh7th/cmp-nvim-lua",     -- Neovim Lua API completion
      
      -- ========================================================================
      -- SNIPPET ENGINE AND INTEGRATION
      -- ========================================================================
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",  -- Build regex support for better snippets
        dependencies = {
          "rafamadriz/friendly-snippets",  -- Collection of pre-made snippets
        },
      },
      "saadparwaiz1/cmp_luasnip",  -- LuaSnip completion source
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- ======================================================================
      -- SNIPPET LOADING
      -- ======================================================================
      -- Load VS Code style snippets from friendly-snippets
      -- This provides snippets for many languages out of the box
      require("luasnip.loaders.from_vscode").lazy_load()
      
      -- ======================================================================
      -- HELPER FUNCTIONS
      -- ======================================================================
      -- Check if there are words before the cursor (for smart tab completion)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      
      -- ======================================================================
      -- COMPLETION MENU ICONS
      -- ======================================================================
      -- COMPLETION MENU ICONS
      -- ======================================================================
      -- Icons to display next to different types of completions
      local kind_icons = {
        Text = "󰉿",          -- Plain text
        Method = "󰆧",        -- Class methods
        Function = "󰊕",      -- Functions
        Constructor = "",    -- Constructors
        Field = "󰜢",         -- Object fields
        Variable = "󰀫",      -- Variables
        Class = "󰠱",         -- Classes
        Interface = "",      -- Interfaces
        Module = "",         -- Modules/imports
        Property = "󰜢",      -- Object properties
        Unit = "󰑭",          -- Units
        Value = "󰎠",         -- Values
        Enum = "",           -- Enumerations
        Keyword = "󰌋",       -- Language keywords
        Snippet = "",        -- Code snippets
        Color = "󰏘",         -- Colors
        File = "󰈙",          -- Files
        Reference = "󰈇",     -- References
        Folder = "󰉋",        -- Folders
        EnumMember = "",     -- Enum members
        Constant = "󰏿",      -- Constants
        Struct = "󰙅",        -- Structures
        Event = "",          -- Events
        Operator = "󰆕",      -- Operators
        TypeParameter = "",  -- Type parameters
      }
      
      -- ======================================================================
      -- NVIM-CMP MAIN CONFIGURATION
      -- ======================================================================
      cmp.setup({
        -- ====================================================================
        -- SNIPPET ENGINE CONFIGURATION
        -- ====================================================================
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)  -- Use LuaSnip to expand snippets
          end,
        },
        
        -- ====================================================================
        -- COMPLETION WINDOW APPEARANCE
        -- ====================================================================
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:BorderBg,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:BorderBg,CursorLine:PmenuSel,Search:None",
          }),
        },
        
        -- ====================================================================
        -- COMPLETION ITEM FORMATTING
        -- ====================================================================
        formatting = {
          fields = { "kind", "abbr", "menu" },  -- Order of fields in completion menu
          format = function(entry, vim_item)
            -- Add kind icons to completion items
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            
            -- Add source indicators to show where completion came from
            vim_item.menu = ({
              nvim_lsp = "[LSP]",      -- Language server
              luasnip = "[Snippet]",   -- Code snippet
              buffer = "[Buffer]",     -- Buffer content
              path = "[Path]",         -- File path
              nvim_lua = "[Lua]",      -- Neovim Lua API
              cmdline = "[Cmd]",       -- Command line
            })[entry.source.name]
            
            return vim_item
          end,
        },
        
        -- ====================================================================
        -- KEY MAPPINGS FOR COMPLETION
        -- ====================================================================
        mapping = cmp.mapping.preset.insert({
          -- Navigate through completion items
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          
          -- Scroll through documentation window
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          
          -- Manually trigger completion menu
          ["<C-Space>"] = cmp.mapping.complete(),
          
          -- Cancel/abort completion
          ["<C-e>"] = cmp.mapping.abort(),
          
          -- Accept currently selected item (don't auto-select first item)
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          
          -- ================================================================
          -- SUPER-TAB FUNCTIONALITY
          -- ================================================================
          -- Tab key does different things based on context:
          -- 1. If completion menu is visible: select next item
          -- 2. If in a snippet: jump to next placeholder
          -- 3. If there are words before cursor: trigger completion
          -- 4. Otherwise: insert normal tab
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()  -- Insert normal tab
            end
          end, { "i", "s" }),  -- Insert and select modes
          
          -- Shift+Tab: reverse of Tab functionality
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        
        -- ====================================================================
        -- COMPLETION SOURCES CONFIGURATION
        -- ====================================================================
        -- Sources are prioritized by their priority value (higher = more important)
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },    -- Language server (highest priority)
          { name = "luasnip", priority = 750 },      -- Snippets
          { name = "nvim_lua", priority = 700 },     -- Neovim Lua API
          { name = "buffer", priority = 500 },       -- Buffer words
          { name = "path", priority = 250 },         -- File paths (lowest priority)
        }),
        
        -- ====================================================================
        -- COMPLETION SORTING CONFIGURATION
        -- ====================================================================
        -- How completion items are sorted in the menu
        sorting = {
          comparators = {
            cmp.config.compare.offset,        -- Prefer items closer to cursor
            cmp.config.compare.exact,         -- Exact matches first
            cmp.config.compare.score,         -- Fuzzy matching score
            cmp.config.compare.recently_used, -- Recently used items
            cmp.config.compare.kind,          -- Group by completion kind
            cmp.config.compare.sort_text,     -- LSP sort text
            cmp.config.compare.length,        -- Shorter items first
            cmp.config.compare.order,         -- Original order
          },
        },
        
        -- ====================================================================
        -- COMPLETION BEHAVIOR
        -- ====================================================================
        completion = {
          completeopt = "menu,menuone,noinsert",  -- Don't auto-insert first item
          keyword_length = 1,                     -- Trigger after 1 character
        },
        
        -- ====================================================================
        -- EXPERIMENTAL FEATURES
        -- ====================================================================
        experimental = {
          ghost_text = true,  -- Show preview of completion as ghost text
        },
      })
      
      -- ======================================================================
      -- FILETYPE-SPECIFIC COMPLETION CONFIGURATIONS
      -- ======================================================================
      
      -- Python: Prioritize LSP and snippets
      cmp.setup.filetype("python", {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
      
      -- TypeScript/JavaScript: Same as Python but for web development
      cmp.setup.filetype({ "typescript", "javascript", "typescriptreact", "javascriptreact" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
      
      -- Lua: Include nvim_lua source for Neovim API completion
      cmp.setup.filetype("lua", {
        sources = cmp.config.sources({
          { name = "nvim_lua", priority = 1000 },   -- Neovim Lua API (highest for config files)
          { name = "nvim_lsp", priority = 900 },    -- Lua language server
          { name = "luasnip", priority = 750 },     -- Snippets
          { name = "buffer", priority = 500 },      -- Buffer words
          { name = "path", priority = 250 },        -- File paths
        }),
      })
      
      -- ======================================================================
      -- COMMAND-LINE COMPLETION
      -- ======================================================================
      
      -- Completion for ':' commands (Ex commands)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },     -- File paths for commands like :edit
          { name = "cmdline" },  -- Neovim commands
        }),
      })
      
      -- Completion for search ('/' and '?')
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },  -- Search buffer content
        },
      })
      
      -- ======================================================================
      -- LUASNIP CONFIGURATION
      -- ======================================================================
      luasnip.config.set_config({
        history = true,                           -- Remember snippet history
        updateevents = "TextChanged,TextChangedI", -- Update snippets on text change
        enable_autosnippets = true,               -- Enable automatic snippets
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = { { "●", "GruvboxOrange" } }, -- Visual indicator for choice nodes
            },
          },
        },
      })
      
      -- ======================================================================
      -- CUSTOM SNIPPETS LOADING
      -- ======================================================================
      -- Load custom snippets from config directory if they exist
      pcall(function()
        require("luasnip.loaders.from_vscode").load({
          paths = { vim.fn.stdpath("config") .. "/snippets" },
        })
      end)
    end,
  },
}

--[[
================================================================================
COMPLETION USAGE GUIDE
================================================================================

KEY MAPPINGS:
Navigation:
- Ctrl+j/k: Navigate completion menu
- Tab/Shift+Tab: Smart tab completion (context-aware)
- Ctrl+Space: Manually trigger completion
- Enter: Accept selected completion
- Ctrl+e: Cancel completion

Documentation:
- Ctrl+f/b: Scroll documentation window

COMPLETION SOURCES (in priority order):
1. LSP: Language server completions (functions, variables, etc.)
2. Snippets: Code templates and boilerplate
3. Neovim Lua: Neovim API (for config files)
4. Buffer: Words from open buffers
5. Path: File and directory paths

SNIPPET USAGE:
- Tab: Expand snippet or jump to next placeholder
- Shift+Tab: Jump to previous placeholder
- Snippets are available for many languages automatically

COMMAND-LINE COMPLETION:
- Works in command mode (:) for Neovim commands
- Works in search mode (/) for buffer content

CUSTOMIZATION:
- Add custom snippets to ~/.config/nvim/snippets/
- Modify source priorities in filetype-specific configurations
- Adjust completion behavior in the main setup function

================================================================================
--]]

