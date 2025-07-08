--[[
================================================================================
BASIC PLUGINS CONFIGURATION
================================================================================
This file contains configurations for essential utility plugins that don't
fit into specific categories like LSP, completion, or UI. These are foundational
plugins that other plugins depend on or provide basic functionality.

Plugins included:
1. plenary.nvim - Lua utility library (required by many plugins)
2. Comment.nvim - Smart commenting functionality
3. GitHub Copilot - AI-powered code completion and suggestions
================================================================================
--]]

return {
  -- ============================================================================
  -- PLENARY.NVIM - LUA UTILITY LIBRARY
  -- ============================================================================
  -- Essential Lua utility library used by many other plugins
  -- Provides common functions for file operations, async programming, etc.
  { 
    "nvim-lua/plenary.nvim", 
    lazy = true  -- Only load when required by other plugins
  },
  
  -- ============================================================================
  -- COMMENT.NVIM - SMART COMMENTING
  -- ============================================================================
  -- Provides intelligent commenting functionality that understands different
  -- file types and can handle complex scenarios like JSX, Vue templates, etc.
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",  -- Load when Neovim becomes idle
    opts = {
      -- Enable basic commenting functionality
      -- The plugin will automatically detect file types and use appropriate comment syntax
    },
    config = function(_, opts)
      require("Comment").setup(opts)
      
      -- Key mappings (these are set automatically by the plugin):
      -- gcc - Toggle line comment
      -- gbc - Toggle block comment
      -- gc{motion} - Comment using motion (e.g., gc2j comments 2 lines down)
      -- gb{motion} - Block comment using motion
      -- In visual mode: gc - Comment selection, gb - Block comment selection
    end,
  },
  
  -- ============================================================================
  -- GITHUB COPILOT - AI CODE ASSISTANCE
  -- ============================================================================
  -- GitHub Copilot provides AI-powered code suggestions and completions
  -- It analyzes your code context and suggests entire lines or functions
  {
    "github/copilot.vim",
    event = "InsertEnter",  -- Load when entering insert mode
    config = function()
      -- ========================================================================
      -- COPILOT CONFIGURATION
      -- ========================================================================
      
      -- Disable default tab mapping to avoid conflicts with completion plugins
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      -- Enable Copilot for specific file types (optional - by default it's enabled for most)
      vim.g.copilot_filetypes = {
        ["*"] = true,           -- Enable for all file types
        ["gitcommit"] = false,  -- Disable for git commit messages
        ["markdown"] = true,    -- Enable for markdown files
        ["yaml"] = true,        -- Enable for YAML files
      }
      
      -- ======================================================================
      -- COPILOT KEY MAPPINGS
      -- ======================================================================
      
      -- Accept Copilot suggestion with Ctrl+J (instead of Tab to avoid conflicts)
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion"
      })
      
      -- Navigate through multiple Copilot suggestions
      vim.keymap.set('i', '<C-L>', '<Plug>(copilot-accept-word)', {
        desc = "Accept next word from Copilot"
      })
      
      vim.keymap.set('i', '<C-K>', '<Plug>(copilot-accept-line)', {
        desc = "Accept current line from Copilot"
      })
      
      -- Manually trigger Copilot suggestions
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-suggest)', {
        desc = "Manually trigger Copilot"
      })
      
      -- Navigate between multiple suggestions
      vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', {
        desc = "Next Copilot suggestion"
      })
      
      vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', {
        desc = "Previous Copilot suggestion"
      })
      
      -- Dismiss Copilot suggestion
      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)', {
        desc = "Dismiss Copilot suggestion"
      })
      
      -- ======================================================================
      -- COPILOT COMMANDS AND USAGE
      -- ======================================================================
      --[[
      Available Copilot commands:
      :Copilot setup    - Initial setup and authentication
      :Copilot enable   - Enable Copilot
      :Copilot disable  - Disable Copilot
      :Copilot status   - Check Copilot status
      :Copilot signout  - Sign out of GitHub account
      :Copilot version  - Show Copilot version
      
      Usage tips:
      1. Start typing and Copilot will suggest completions in gray text
      2. Press Ctrl+J to accept the suggestion
      3. Press Ctrl+K to accept only the current line
      4. Press Ctrl+L to accept only the next word
      5. Use Alt+] and Alt+[ to cycle through multiple suggestions
      6. Press Ctrl+] to dismiss the current suggestion
      
      Copilot works best when you:
      - Write descriptive comments about what you want to do
      - Use meaningful variable and function names
      - Provide context through existing code
      - Write clear function signatures
      --]]
    end,
  },
  
  -- ============================================================================
  -- ADDITIONAL UTILITY PLUGINS
  -- ============================================================================
  -- You can add more basic utility plugins here as needed
  -- Examples might include:
  -- - vim-repeat for better repeat functionality
  -- - vim-surround for text object manipulation
  -- - etc.
}

--[[
================================================================================
PLUGIN USAGE SUMMARY
================================================================================

COMMENTING (Comment.nvim):
- gcc: Toggle line comment
- gbc: Toggle block comment  
- gc + motion: Comment using motion
- Visual mode + gc: Comment selection

GITHUB COPILOT:
- Ctrl+J: Accept suggestion
- Ctrl+K: Accept current line
- Ctrl+L: Accept next word
- Ctrl+\: Manually trigger
- Alt+]: Next suggestion
- Alt+[: Previous suggestion
- Ctrl+]: Dismiss suggestion

SETUP COPILOT:
1. Run :Copilot setup in Neovim
2. Follow the authentication process
3. Start coding and enjoy AI assistance!

================================================================================
--]]
