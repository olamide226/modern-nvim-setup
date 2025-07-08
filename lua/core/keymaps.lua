-- core/keymaps.lua - Neovim keymaps configuration

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

------------------------------------------
-- General Mappings
------------------------------------------
-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quick save and quit
map("n", "<leader>w", ":w<CR>", { desc = "Save file", noremap = true, silent = true })
map("n", "<leader>q", ":q<CR>", { desc = "Quit", noremap = true, silent = true })
map("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all", noremap = true, silent = true })

-- Clear search highlights
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights", noremap = true, silent = true })

-- Escape to normal mode from terminal
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode", noremap = true, silent = true })

-- Reload configuration
map("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Reload vimrc", noremap = true, silent = true })

------------------------------------------
-- Window Navigation
------------------------------------------
-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window", noremap = true, silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to bottom window", noremap = true, silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate to top window", noremap = true, silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window", noremap = true, silent = true })

-- Window management
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically", noremap = true, silent = true })
map("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally", noremap = true, silent = true })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size", noremap = true, silent = true })
map("n", "<leader>sx", ":close<CR>", { desc = "Close current window", noremap = true, silent = true })

-- Window resizing
map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height", noremap = true, silent = true })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height", noremap = true, silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", noremap = true, silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", noremap = true, silent = true })

------------------------------------------
-- Buffer Navigation
------------------------------------------
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", noremap = true, silent = true })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer", noremap = true, silent = true })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer", noremap = true, silent = true })
map("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Close all buffers", noremap = true, silent = true })
map("n", "<leader>bn", ":enew<CR>", { desc = "New buffer", noremap = true, silent = true })

------------------------------------------
-- Text Manipulation
------------------------------------------
-- Move text up and down
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", noremap = true, silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", noremap = true, silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", noremap = true, silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", noremap = true, silent = true })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left and keep selection", noremap = true, silent = true })
map("v", ">", ">gv", { desc = "Indent right and keep selection", noremap = true, silent = true })

-- Paste without overwriting register
map("v", "p", '"_dP', { desc = "Paste without overwriting register", noremap = true, silent = true })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all text", noremap = true, silent = true })

-- Duplicate line
map("n", "<leader>dl", "yyp", { desc = "Duplicate line", noremap = true, silent = true })

------------------------------------------
-- Search and Replace
------------------------------------------
-- Search word under cursor
map("n", "<leader>sw", "*", { desc = "Search word under cursor", noremap = true, silent = true })

-- Quick substitute in current line
map("n", "<leader>ss", ":s/", { desc = "Substitute in current line", noremap = true })

-- Quick substitute in entire file
map("n", "<leader>S", ":%s/", { desc = "Substitute in entire file", noremap = true })

------------------------------------------
-- LSP Mappings
------------------------------------------
-- These will be enabled when LSP attaches to a buffer
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", noremap = true, silent = true })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", noremap = true, silent = true })
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation", noremap = true, silent = true })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", noremap = true, silent = true })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help", noremap = true, silent = true })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", noremap = true, silent = true })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions", noremap = true, silent = true })
map("n", "gr", vim.lsp.buf.references, { desc = "Show references", noremap = true, silent = true })
map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format code", noremap = true, silent = true })

------------------------------------------
-- Diagnostic Mappings
------------------------------------------
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics", noremap = true, silent = true })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic", noremap = true, silent = true })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", noremap = true, silent = true })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Set diagnostic list", noremap = true, silent = true })

------------------------------------------
-- Language Specific
------------------------------------------
-- Python
map("n", "<leader>py", ":!python %<CR>", { desc = "Run Python file", noremap = true, silent = true })
map("n", "<leader>pt", ":lua require('dap-python').test_method()<CR>", { desc = "Test Python method", noremap = true, silent = true })
map("n", "<leader>pc", ":lua require('dap-python').test_class()<CR>", { desc = "Test Python class", noremap = true, silent = true })
map("n", "<leader>vs", ":VenvSelect<CR>", { desc = "Select Python venv", noremap = true, silent = true })
map("n", "<leader>vc", ":VenvSelectCached<CR>", { desc = "Select cached Python venv", noremap = true, silent = true })

-- TypeScript/JavaScript
map("n", "<leader>js", ":!node %<CR>", { desc = "Run JavaScript file", noremap = true, silent = true })
map("n", "<leader>ti", ":TypescriptAddMissingImports<CR>", { desc = "Add missing imports", noremap = true, silent = true })
map("n", "<leader>to", ":TypescriptOrganizeImports<CR>", { desc = "Organize imports", noremap = true, silent = true })
map("n", "<leader>tr", ":TypescriptRenameFile<CR>", { desc = "Rename file", noremap = true, silent = true })

------------------------------------------
-- Plugin Specific
------------------------------------------
-- These will be enabled when the respective plugins are installed

-- File Explorer (depends on nvim-tree.lua)
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer", noremap = true, silent = true })
map("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "Focus file explorer", noremap = true, silent = true })

-- Fuzzy Finder (depends on telescope.nvim)
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files", noremap = true, silent = true })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep", noremap = true, silent = true })
map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers", noremap = true, silent = true })
map("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags", noremap = true, silent = true })
map("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files", noremap = true, silent = true })
map("n", "<leader>fc", ":Telescope colorscheme<CR>", { desc = "Colorscheme selector", noremap = true, silent = true })
map("n", "<leader>fd", ":Telescope diagnostics<CR>", { desc = "List diagnostics", noremap = true, silent = true })

-- Terminal (depends on toggleterm.nvim)
map("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { desc = "Floating terminal", noremap = true, silent = true })
map("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { desc = "Horizontal terminal", noremap = true, silent = true })
map("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", { desc = "Vertical terminal", noremap = true, silent = true })

------------------------------------------
-- Terminal Mappings
------------------------------------------
-- Better terminal navigation (when in terminal mode)
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Terminal left window nav", noremap = true, silent = true })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Terminal down window nav", noremap = true, silent = true })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Terminal up window nav", noremap = true, silent = true })
map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Terminal right window nav", noremap = true, silent = true })

