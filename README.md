# 🚀 Modern Neovim Configuration

A comprehensive, well-documented Neovim configuration built for modern development workflows. This setup provides a powerful IDE-like experience while maintaining the speed and flexibility of Neovim.

## ✨ Features

### 🤖 AI-Powered Development
- **GitHub Copilot** integration with custom key mappings
- Context-aware code suggestions and completions
- Multi-language AI assistance

### 🔧 Language Support
- **Python**: Pyright LSP, virtual environment management, debugging
- **TypeScript/JavaScript**: ts_ls LSP, Jest/Vitest testing, ESLint integration
- **Lua**: lua_ls LSP with Neovim API completion
- **Auto-installation** of language servers via Mason

### 💡 Intelligent Code Completion
- **nvim-cmp** with multiple sources (LSP, snippets, buffer, path)
- Smart Tab completion with context awareness
- Snippet expansion with LuaSnip
- Command-line and search completion

### 🎨 Modern UI
- **Catppuccin** theme with customizable variants
- **Lualine** status line with git and LSP integration
- **Bufferline** for tab-like buffer management
- **nvim-tree** file explorer with git integration
- **Telescope** fuzzy finder for files, grep, and symbols

### 🧪 Testing & Debugging
- **Neotest** framework with Python and JavaScript adapters
- **nvim-dap** debugging for Python and JavaScript
- **Coverage** visualization and reporting
- Test analytics and reporting tools

### 📝 Development Tools
- **Git integration** with Gitsigns (blame, diff, hunks)
- **Comment.nvim** for intelligent commenting
- **Treesitter** for advanced syntax highlighting
- **Auto-pairs** and **auto-tagging** for HTML/JSX
- **Which-key** for discoverable key mappings

## 🚀 Quick Start

### Prerequisites
- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)
- Node.js (for TypeScript support)
- Python 3.8+ (for Python support)

### Installation

1. **Backup existing configuration** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **Launch Neovim**:
   ```bash
   nvim
   ```
   Plugins will be automatically installed on first launch.

4. **Install language servers**:
   ```vim
   :Mason
   ```

5. **Setup GitHub Copilot** (optional):
   ```vim
   :Copilot setup
   ```

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── README.md                   # This file
├── SETUP_GUIDE.md             # Detailed usage guide
└── lua/
    ├── core/                  # Core Neovim settings
    │   ├── options.lua        # Editor options and settings
    │   ├── keymaps.lua        # Key mappings
    │   └── autocmds.lua       # Auto commands
    ├── plugins/               # Plugin configurations
    │   ├── init.lua           # Basic plugins (Copilot, Comment, etc.)
    │   ├── lsp/               # LSP configurations
    │   │   └── init.lua       # Language server setup
    │   ├── completion.lua     # Completion engine (nvim-cmp)
    │   ├── ui.lua             # UI enhancements
    │   ├── tools.lua          # Development tools (Telescope, Git)
    │   ├── debug.lua          # Debugging configuration
    │   └── test*.lua          # Testing framework
    └── lang/                  # Language-specific configurations
        └── python.lua         # Python-specific settings
```

## ⌨️ Key Mappings

### Leader Key: `<Space>`

#### File Navigation
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |

#### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show references |
| `K` | Hover documentation |
| `<space>ca` | Code actions |
| `<space>rn` | Rename symbol |
| `<space>f` | Format buffer |

#### GitHub Copilot
| Key | Action |
|-----|--------|
| `Ctrl+J` | Accept suggestion |
| `Ctrl+L` | Accept word |
| `Ctrl+K` | Accept line |
| `Alt+]` | Next suggestion |
| `Alt+[` | Previous suggestion |
| `Ctrl+]` | Dismiss suggestion |

#### Python Development
| Key | Action |
|-----|--------|
| `<leader>vs` | Select virtual environment |
| `<leader>vc` | Select cached virtual environment |

#### Git
| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame |
| `<leader>gd` | Git diff |

## 🎨 Customization

### Changing Theme
Edit `lua/plugins/ui.lua` and modify the Catppuccin setup or replace with your preferred colorscheme.

### Adding Language Servers
1. Open Mason: `:Mason`
2. Install your language server
3. Add configuration in `lua/plugins/lsp/init.lua`

### Custom Snippets
Create snippet files in `~/.config/nvim/snippets/`:
```
snippets/
├── python.json
├── javascript.json
└── lua.json
```

### Key Mapping Changes
Modify `lua/core/keymaps.lua` for global mappings or individual plugin files for plugin-specific mappings.

## 🔧 Troubleshooting

### Common Issues

1. **LSP not working**: Run `:LspInfo` and `:Mason` to check server status
2. **Copilot not suggesting**: Run `:Copilot status` and `:Copilot setup`
3. **Completion not working**: Run `:checkhealth nvim-cmp`
4. **Python issues**: Use `:VenvSelect` to choose the correct environment

### Performance
- Check `:checkhealth` for any issues
- Disable unused plugins in configuration files
- Adjust `updatetime` in `lua/core/options.lua`

## 📚 Documentation

This configuration is extensively documented:
- Every configuration file includes comprehensive comments
- `SETUP_GUIDE.md` provides detailed usage instructions
- Inline help available via `:help` for Neovim features

## 🤝 Contributing

Feel free to:
- Report issues or bugs
- Suggest improvements
- Submit pull requests
- Share your customizations

## 📄 License

This configuration is provided as-is for educational and personal use. Feel free to modify and distribute according to your needs.

## 🙏 Acknowledgments

Built with these amazing plugins and tools:
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Completion engine
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [catppuccin](https://github.com/catppuccin/nvim) - Theme
- And many more amazing plugins from the Neovim community!

---

**Happy coding with Neovim!** 🎉
