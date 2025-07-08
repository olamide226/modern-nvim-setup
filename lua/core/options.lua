--[[
================================================================================
NEOVIM CORE OPTIONS CONFIGURATION
================================================================================
This file contains all the core Neovim options and settings that control
the editor's behavior, appearance, and functionality. These settings are
applied when Neovim starts and affect the overall editing experience.

Categories covered:
1. General Settings - Basic editor behavior
2. UI Settings - Visual appearance and interface
3. Indentation and Tabs - Code formatting behavior
4. Search Settings - Search and pattern matching
5. Split Windows - Window management
6. Completion - Completion behavior
7. Formatting and Text Display - Text rendering and display
8. Folds - Code folding configuration
9. Global Variables - Neovim-specific variables
================================================================================
--]]

local opt = vim.opt  -- Shorthand for vim.opt
local g = vim.g      -- Shorthand for vim.g (global variables)

--[[
================================================================================
GENERAL SETTINGS
================================================================================
Basic editor behavior and file handling options
--]]
opt.mouse = "a"                          -- Enable mouse support in all modes (normal, visual, insert, command)
opt.clipboard = "unnamedplus"            -- Use system clipboard for all yank/delete/put operations
opt.swapfile = false                     -- Disable swap files (can cause issues with file watchers)
opt.backup = false                       -- Don't create backup files before overwriting
opt.writebackup = false                  -- Don't create backup files during write operations
opt.undofile = true                      -- Enable persistent undo (survives Neovim restarts)
opt.updatetime = 250                     -- Faster completion and diagnostics (default: 4000ms)
opt.timeoutlen = 300                     -- Time to wait for mapped sequence completion (default: 1000ms)
opt.fileencoding = "utf-8"               -- Default file encoding for new files
opt.hidden = true                        -- Allow switching from unsaved buffers without warnings

--[[
================================================================================
UI SETTINGS
================================================================================
Visual appearance and user interface configuration
--]]
opt.number = true                        -- Show absolute line numbers
opt.relativenumber = true                -- Show relative line numbers (great for motions like 5j, 3k)
opt.cursorline = true                    -- Highlight the current line
opt.signcolumn = "yes"                   -- Always show sign column (prevents text shifting)
opt.colorcolumn = "80"                   -- Highlight column 80 (traditional line length limit)
opt.wrap = false                         -- Don't wrap long lines (horizontal scrolling instead)
opt.scrolloff = 8                        -- Keep 8 lines visible above/below cursor when scrolling
opt.sidescrolloff = 8                    -- Keep 8 columns visible left/right of cursor
opt.termguicolors = true                 -- Enable 24-bit RGB colors (required for modern themes)
opt.background = "dark"                  -- Tell Neovim we're using a dark background
opt.showmode = false                     -- Don't show mode in command line (statusline shows it)
opt.showtabline = 2                      -- Always show tabline (even with single tab)
opt.title = true                         -- Set terminal/window title to current file
opt.shortmess:append("c")                -- Don't show completion messages in command line
opt.cmdheight = 1                        -- Height of command line (1 line)
opt.pumheight = 10                       -- Maximum number of items in popup menu

--[[
================================================================================
INDENTATION AND TABS
================================================================================
Code formatting and indentation behavior
--]]
opt.expandtab = true                     -- Convert tabs to spaces
opt.shiftwidth = 4                       -- Number of spaces for each indentation level
opt.tabstop = 4                          -- Number of spaces a tab character represents
opt.softtabstop = 4                      -- Number of spaces tab counts for when editing
opt.smartindent = true                   -- Smart auto-indenting for new lines
opt.autoindent = true                    -- Copy indent from current line when starting new line
opt.shiftround = true                    -- Round indent to multiple of 'shiftwidth'

--[[
================================================================================
SEARCH SETTINGS
================================================================================
Search and pattern matching configuration
--]]
opt.hlsearch = true                      -- Highlight all search matches
opt.incsearch = true                     -- Show search matches as you type (incremental search)
opt.ignorecase = true                    -- Ignore case when searching
opt.smartcase = true                     -- Override ignorecase if search contains uppercase letters

--[[
================================================================================
SPLIT WINDOWS
================================================================================
Window splitting behavior
--]]
opt.splitbelow = true                    -- Horizontal splits open below current window
opt.splitright = true                    -- Vertical splits open to the right of current window

--[[
================================================================================
COMPLETION
================================================================================
Code completion behavior
--]]
opt.completeopt = {"menuone", "noselect", "noinsert"} -- Completion menu behavior:
                                         -- menuone: show menu even for single match
                                         -- noselect: don't auto-select first item
                                         -- noinsert: don't auto-insert completion
opt.wildmode = "longest:full,full"       -- Command-line completion mode:
                                         -- longest:full: complete longest common string, then full
                                         -- full: complete next full match

--[[
================================================================================
FORMATTING AND TEXT DISPLAY
================================================================================
Text rendering and visual formatting options
--]]
opt.list = true                          -- Show invisible characters
opt.listchars = {                        -- Define how invisible characters are displayed
  tab = "→ ",                            -- Show tabs as arrows
  trail = "·",                           -- Show trailing spaces as dots
  extends = "»",                         -- Show when line extends beyond screen
  precedes = "«",                        -- Show when line precedes screen
  nbsp = "␣"                             -- Show non-breaking spaces
}
opt.showbreak = "↪ "                     -- Symbol shown at beginning of wrapped lines
opt.linebreak = true                     -- Wrap lines at convenient points (word boundaries)
opt.fillchars = {                        -- Characters used for various UI elements
  eob = " ",                             -- Empty lines at end of buffer (no ~)
  fold = " ",                            -- Fold lines
  foldopen = "▾",                        -- Open fold marker
  foldsep = " ",                         -- Fold separator
  foldclose = "▸",                       -- Closed fold marker
}

--[[
================================================================================
FOLDS
================================================================================
Code folding configuration
--]]
opt.foldlevelstart = 99                  -- Start with all folds open
opt.foldmethod = "indent"                -- Fold based on indentation
opt.foldnestmax = 10                     -- Maximum fold nesting level

--[[
================================================================================
GLOBAL VARIABLES
================================================================================
Neovim-specific global variables and provider settings
--]]
g.loaded_perl_provider = 0               -- Disable Perl provider (faster startup)
g.loaded_ruby_provider = 0               -- Disable Ruby provider (faster startup)

--[[
================================================================================
ADDITIONAL CONFIGURATION
================================================================================
Miscellaneous settings and path configurations
--]]
-- Add .lua extension to suffixesadd for 'gf' command (go to file)
vim.opt.suffixesadd:append(".lua")

-- Set file format preferences
opt.fileformat = "unix"                  -- Use Unix line endings by default
opt.fileformats = "unix,dos"             -- Recognize Unix and DOS line endings

-- Set path for file search (used by :find, gf, etc.)
opt.path:append("**")                    -- Search in subdirectories recursively

-- Set keyword characters (affects word boundaries for w, b, *, etc.)
opt.iskeyword:append("-")                -- Consider hyphen as part of a word

--[[
================================================================================
CONFIGURATION NOTES
================================================================================

PERFORMANCE OPTIMIZATIONS:
- Disabled swap files and backups for better performance with file watchers
- Disabled unused providers (Perl, Ruby) for faster startup
- Set reasonable updatetime for responsive diagnostics

EDITOR BEHAVIOR:
- Persistent undo allows undoing changes after closing/reopening files
- Smart case search: case-insensitive unless uppercase letters are used
- Hidden buffers allow switching without saving (use with caution)

UI ENHANCEMENTS:
- Relative line numbers make motions like 5j, 10k more intuitive
- Sign column always visible prevents text jumping when diagnostics appear
- Colorcolumn at 80 characters follows traditional coding standards

INDENTATION:
- 4-space indentation is used by default (common for Python, many other languages)
- Smart indenting automatically adjusts indentation for new lines
- Expandtab converts tabs to spaces for consistent formatting

SEARCH:
- Incremental search shows matches as you type
- Smart case: lowercase = case-insensitive, mixed case = case-sensitive
- Search highlighting helps visualize all matches

CUSTOMIZATION:
- Modify shiftwidth/tabstop for different indentation preferences
- Adjust scrolloff for more/less context when scrolling
- Change colorcolumn value for different line length standards
- Modify listchars to customize invisible character display

================================================================================
--]]

