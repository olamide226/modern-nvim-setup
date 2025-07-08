--[[
================================================================================
NEOVIM CONFIGURATION - MAIN ENTRY POINT
================================================================================
This is the main configuration file for Neovim. It sets up:
1. Leader keys for custom shortcuts
2. Lazy.nvim plugin manager bootstrap and configuration
3. Basic Neovim options that need to be set early
4. Core module loading with error handling
5. Language-specific configurations

The configuration follows a modular structure:
- core/: Basic Neovim settings (options, keymaps, autocommands)
- plugins/: Plugin configurations organized by functionality
- lang/: Language-specific settings and configurations
================================================================================
--]]

-- ============================================================================
-- LEADER KEY SETUP
-- ============================================================================
-- Set leader keys BEFORE lazy.nvim loads to ensure plugins can use them
-- Leader key is used as a prefix for custom shortcuts (e.g., <leader>ff for find files)
vim.g.mapleader = " "        -- Space as main leader key
vim.g.maplocalleader = " "   -- Space as local leader key (for buffer-specific mappings)

-- ============================================================================
-- LAZY.NVIM PLUGIN MANAGER BOOTSTRAP
-- ============================================================================
-- This section automatically installs lazy.nvim if it's not already installed
-- lazy.nvim is a modern plugin manager that loads plugins on-demand for better performance
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- Clone lazy.nvim from GitHub if it doesn't exist
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",        -- Partial clone for faster download
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",           -- Use stable branch
    lazypath,
  })
end
-- Add lazy.nvim to Neovim's runtime path so it can be required
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- DIRECTORY STRUCTURE SETUP
-- ============================================================================
-- Ensure required directories exist for our modular configuration
-- This prevents errors when lazy.nvim tries to load modules
local function ensure_directory(dir)
  local full_path = vim.fn.stdpath("config") .. "/" .. dir
  if vim.fn.isdirectory(full_path) == 0 then
    vim.fn.mkdir(full_path, "p")  -- Create directory recursively
  end
end

-- Create all necessary directories for our configuration structure
ensure_directory("lua/core")              -- Core Neovim settings
ensure_directory("lua/plugins/lsp")       -- LSP configurations
ensure_directory("lua/plugins/completion") -- Completion setup
ensure_directory("lua/plugins/tools")     -- Development tools
ensure_directory("lua/plugins/ui")        -- UI enhancements
ensure_directory("lua/lang")              -- Language-specific configs

-- ============================================================================
-- GLOBAL UTILITIES
-- ============================================================================
-- Create a global utility module for helper functions used across configs
_G.utils = {}

-- Helper function to check if a plugin is available/loaded
-- Usage: if utils.has("telescope.nvim") then ... end
_G.utils.has = function(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

-- ============================================================================
-- ESSENTIAL NEOVIM OPTIONS
-- ============================================================================
-- These options need to be set early, before plugins load
-- More comprehensive options are in lua/core/options.lua

-- Completion behavior
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.mouse = "a"              -- Enable mouse support in all modes
vim.opt.splitright = true        -- Vertical splits open to the right
vim.opt.splitbelow = true        -- Horizontal splits open below
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.tabstop = 4              -- Number of spaces a tab represents
vim.opt.shiftwidth = 4           -- Number of spaces for auto-indentation
vim.opt.number = true            -- Show line numbers
vim.opt.ignorecase = true        -- Ignore case in search patterns
vim.opt.incsearch = true         -- Show search matches as you type
vim.opt.diffopt:append("vertical") -- Vertical diff splits
vim.opt.hidden = true            -- Allow switching buffers without saving
vim.opt.backup = false           -- Don't create backup files
vim.opt.writebackup = false      -- Don't create backup during write
vim.opt.cmdheight = 1            -- Height of command line
vim.opt.shortmess:append("c")    -- Don't show completion messages
vim.opt.signcolumn = "yes"       -- Always show sign column (for git, diagnostics)
vim.opt.updatetime = 250         -- Faster completion and diagnostics

-- Enable file type detection and plugins
vim.cmd [[filetype plugin indent on]]

-- Enable true color support if terminal supports it
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- ============================================================================
-- LAZY.NVIM PLUGIN CONFIGURATION
-- ============================================================================
-- Setup lazy.nvim with all plugin configurations
-- Plugins are organized in separate files for better maintainability:
-- - plugins/init.lua: Basic utility plugins
-- - plugins/lsp/: Language Server Protocol configurations
-- - plugins/completion.lua: Code completion setup
-- - plugins/tools.lua: Development tools (Telescope, Git, etc.)
-- - plugins/ui.lua: User interface enhancements
require("lazy").setup({
  -- ========================================================================
  -- PLUGIN MODULE IMPORTS
  -- ========================================================================
  -- Import all plugin configurations from their respective files
  { import = "plugins" },           -- Basic plugins (Comment, Copilot, etc.)
  { import = "plugins.lsp" },       -- LSP configurations (language servers)
  { import = "plugins.completion" }, -- Completion engine and sources
  { import = "plugins.tools" },     -- Development tools (Telescope, Git, etc.)
  { import = "plugins.ui" },        -- UI enhancements (theme, statusline, etc.)
  
  -- ========================================================================
  -- PYTHON VIRTUAL ENVIRONMENT SUPPORT
  -- ========================================================================
  -- Plugin for managing Python virtual environments within Neovim
  -- Allows switching between different Python environments for projects
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { 
      "neovim/nvim-lspconfig",        -- LSP integration
      "nvim-telescope/telescope.nvim", -- Telescope picker integration
      "mfussenegger/nvim-dap-python"  -- Debug adapter integration
    },
    opts = {
      name = ".venv",                 -- Look for .venv directories
      auto_refresh = true,            -- Automatically refresh available environments
      search = true,                  -- Search for environments in project
      dap_enabled = false,            -- Disable debug adapter integration for now
      notify_user_on_activate = true, -- Show notification when switching environments
    },
    keys = {
      -- Key mappings for virtual environment management
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Virtual Environment" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached Virtual Environment" },
    },
    event = "VeryLazy", -- Load when Neovim is idle
  },
  
  -- ========================================================================
  -- LAZY.NVIM CONFIGURATION OPTIONS
  -- ========================================================================
  defaults = { 
    lazy = true  -- Load plugins on-demand by default for better performance
  },
  install = { 
    colorscheme = { "catppuccin" }  -- Use catppuccin theme during plugin installation
  },
  checker = { 
    enabled = true  -- Automatically check for plugin updates
  },
  performance = {
    rtp = {
      -- Disable unused built-in plugins for better startup performance
      disabled_plugins = {
        "gzip",        -- Gzip file support
        "matchit",     -- Extended % matching
        "matchparen",  -- Highlight matching parentheses
        "netrwPlugin", -- Built-in file explorer (we use nvim-tree)
        "tarPlugin",   -- Tar file support
        "tohtml",      -- Convert to HTML
        "tutor",       -- Neovim tutor
        "zipPlugin",   -- Zip file support
      },
    },
  },
})

-- ============================================================================
-- PYTHON CONFIGURATION
-- ============================================================================
-- Set Python3 host program for Neovim's Python integration
-- This is used by plugins that require Python support
if vim.g.python3_host_prog == nil then
  vim.g.python3_host_prog = vim.fn.stdpath("config") .. "/.venv/bin/python"
end

-- ============================================================================
-- CORE MODULE LOADING
-- ============================================================================
-- Load core configuration modules with error handling
-- These modules contain essential Neovim settings and configurations
local core_modules = {
  "core.options",   -- Editor options and settings
  "core.keymaps",   -- Key mappings and shortcuts
  "core.autocmds"   -- Automatic commands and event handlers
}

-- Load each core module with error handling
for _, module in ipairs(core_modules) do
  local ok, err = pcall(require, module)
  if not ok then
    -- Show warning if module fails to load, but don't crash Neovim
    vim.notify("Failed to load " .. module .. ": " .. err, vim.log.levels.WARN)
  end
end

-- ============================================================================
-- LANGUAGE-SPECIFIC CONFIGURATIONS
-- ============================================================================
-- Load language-specific configurations
-- These modules contain settings tailored for specific programming languages
local lang_modules = {
  "lang.python",     -- Python-specific settings and tools
  "lang.typescript"  -- TypeScript/JavaScript-specific settings
}

-- Load each language module (silently fail if not found)
for _, module in ipairs(lang_modules) do
  pcall(require, module)
end

--[[
================================================================================
CONFIGURATION LOADING COMPLETE
================================================================================
At this point, all configurations should be loaded:
1. ✅ Leader keys set
2. ✅ Lazy.nvim bootstrapped and configured
3. ✅ All plugins loaded from modular files
4. ✅ Core settings applied (options, keymaps, autocommands)
5. ✅ Language-specific configurations loaded
6. ✅ Python environment support configured

Your Neovim is now ready with:
- Full LSP support for Python, TypeScript, and Lua
- Advanced completion with nvim-cmp
- Fuzzy finding with Telescope
- Git integration with Gitsigns
- Modern UI with Catppuccin theme
- Testing framework with Neotest
- Debugging support with nvim-dap
- GitHub Copilot AI assistance
- And much more!

Key shortcuts to remember:
- <Space> is your leader key
- <leader>ff: Find files
- <leader>fg: Live grep
- <leader>vs: Select Python virtual environment
- gd: Go to definition
- K: Show hover documentation
================================================================================
--]]
