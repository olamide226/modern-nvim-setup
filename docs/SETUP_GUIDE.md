# Neovim Configuration Setup Guide

## 🚀 Quick Start

Your Neovim configuration is now fully set up with comprehensive comments and optimizations! Here's how to get started:

### 1. First Launch
```bash
nvim
```

### 2. Install Language Servers
```vim
:Mason
```
This will open the Mason UI where you can see and install language servers.

### 3. Setup GitHub Copilot
```vim
:Copilot setup
```
Follow the authentication process to enable AI assistance.

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point with comprehensive comments
├── SETUP_GUIDE.md             # This guide
├── lazy-lock.json             # Plugin version lock file
└── lua/
    ├── core/                  # Core Neovim settings
    │   ├── options.lua        # Editor options (fully commented)
    │   ├── keymaps.lua        # Key mappings
    │   └── autocmds.lua       # Auto commands
    ├── plugins/               # Plugin configurations
    │   ├── init.lua           # Basic plugins + Copilot setup
    │   ├── lsp/               # LSP configurations
    │   │   └── init.lua       # Language servers (Python, TS, Lua)
    │   ├── completion.lua     # nvim-cmp completion engine
    │   ├── ui.lua             # UI enhancements
    │   ├── tools.lua          # Development tools
    │   ├── debug.lua          # Debugging setup
    │   └── test*.lua          # Testing framework
    └── lang/                  # Language-specific configs
        └── python.lua         # Python-specific settings
```

## 🔧 Key Features & Usage

### GitHub Copilot (AI Assistant)
- **Setup**: `:Copilot setup` (first time only)
- **Accept suggestion**: `Ctrl+J`
- **Accept word**: `Ctrl+L`
- **Accept line**: `Ctrl+K`
- **Next suggestion**: `Alt+]`
- **Previous suggestion**: `Alt+[`
- **Dismiss**: `Ctrl+]`
- **Manual trigger**: `Ctrl+\`

### Language Server Protocol (LSP)
- **Go to definition**: `gd`
- **Go to declaration**: `gD`
- **Show references**: `gr`
- **Hover documentation**: `K`
- **Rename symbol**: `<space>rn`
- **Code actions**: `<space>ca`
- **Format buffer**: `<space>f`

### Code Completion
- **Navigate menu**: `Ctrl+j/k`
- **Smart Tab**: `Tab` (context-aware)
- **Accept completion**: `Enter`
- **Trigger manually**: `Ctrl+Space`
- **Cancel**: `Ctrl+e`

### File Navigation (Telescope)
- **Find files**: `<leader>ff`
- **Live grep**: `<leader>fg`
- **Recent files**: `<leader>fr`
- **Buffers**: `<leader>fb`
- **Git files**: `<leader>gf`

### Python Development
- **Select virtual env**: `<leader>vs`
- **Cached virtual env**: `<leader>vc`
- **Run tests**: `<leader>tt`
- **Debug**: `<F5>`

### Git Integration
- **Git status**: `<leader>gs`
- **Git blame**: `<leader>gb`
- **Git diff**: `<leader>gd`

## 🎯 Language Support

### Python
- ✅ Pyright LSP server
- ✅ Virtual environment management
- ✅ Debugging with nvim-dap
- ✅ Testing with pytest/unittest
- ✅ Code formatting and linting

### TypeScript/JavaScript
- ✅ ts_ls language server
- ✅ Jest/Vitest testing
- ✅ ESLint integration
- ✅ Auto-completion and navigation

### Lua
- ✅ lua_ls language server
- ✅ Neovim API completion
- ✅ Perfect for config editing

## 🔧 Customization

### Adding New Language Servers
1. Open Mason: `:Mason`
2. Search for your language server
3. Install it with `i`
4. Add configuration in `lua/plugins/lsp/init.lua`

### Custom Snippets
Create files in `~/.config/nvim/snippets/` directory:
```
snippets/
├── python.json
├── javascript.json
└── lua.json
```

### Theme Customization
Edit `lua/plugins/ui.lua` to change:
- Colorscheme (currently Catppuccin)
- Statusline appearance
- Buffer line style

## 🚨 Troubleshooting

### Common Issues

1. **LSP not working**
   ```vim
   :LspInfo
   :Mason
   ```

2. **Copilot not suggesting**
   ```vim
   :Copilot status
   :Copilot setup
   ```

3. **Completion not working**
   ```vim
   :checkhealth nvim-cmp
   ```

4. **Python virtual environment issues**
   ```vim
   :VenvSelect
   ```

### Performance Issues
- Check `:checkhealth`
- Disable unused plugins in `init.lua`
- Reduce `updatetime` in `core/options.lua`

## 📚 Learning Resources

### Key Concepts to Master
1. **Motions**: `w`, `b`, `e`, `f`, `t`, `%`
2. **Text Objects**: `iw`, `aw`, `i"`, `a"`
3. **Operators**: `d`, `c`, `y`, `v`
4. **Registers**: `"ay`, `"ap`
5. **Marks**: `ma`, `'a`

### Recommended Practice
1. Use `vimtutor` for basics
2. Practice with real projects
3. Gradually learn advanced features
4. Customize as you go

## 🔄 Updates and Maintenance

### Update Plugins
```vim
:Lazy update
```

### Update Language Servers
```vim
:Mason
# Press 'U' to update all
```

### Backup Configuration
```bash
cp -r ~/.config/nvim ~/nvim-backup-$(date +%Y%m%d)
```

## 🎉 You're Ready!

Your Neovim setup includes:
- ✅ 40+ carefully configured plugins
- ✅ Comprehensive LSP support
- ✅ AI assistance with GitHub Copilot
- ✅ Advanced completion engine
- ✅ Testing and debugging tools
- ✅ Modern UI with great themes
- ✅ Extensive documentation and comments

Start coding and enjoy your supercharged development environment! 🚀

---

*Need help? Check the comments in each configuration file - they explain everything in detail!*
