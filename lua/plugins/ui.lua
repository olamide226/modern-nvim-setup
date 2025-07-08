-- plugins/ui.lua - UI enhancement configurations

return {
  -- Colorscheme: Catppuccin (modern, clean theme with good contrast)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this before other plugins
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          notify = true,
          mini = true,
          -- For treesitter:
          treesitter = true,
          -- For native LSP:
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          -- For indent-blankline:
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
        },
        color_overrides = {},
        custom_highlights = {},
      })
      
      -- Set colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline: Lualine (configurable statusline with sections)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "starter" },
            winbar = { "dashboard", "alpha", "starter" },
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
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { 
            "branch", 
            {
              "diff",
              symbols = {
                added = " ", 
                modified = " ", 
                removed = " "
              },
              diff_color = {
                added = { fg = "#98be65" },
                modified = { fg = "#51afef" },
                removed = { fg = "#ec5f67" },
              },
            },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = { 
                error = " ", 
                warn = " ", 
                info = " ", 
                hint = " " 
              },
            },
          },
          lualine_c = { 
            { "filename", path = 1 },
          },
          lualine_x = { 
            -- Show active LSP clients
            {
              function()
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                  return "No LSP"
                end
                
                local client_names = {}
                for _, client in ipairs(clients) do
                  -- Skip null-ls as it's usually abundant
                  if client.name ~= "null-ls" then
                    table.insert(client_names, client.name)
                  end
                end
                
                return "LSP: " .. table.concat(client_names, ", ")
              end,
            },
            "encoding",
            "fileformat",
            "filetype"
          },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "nvim-tree", "toggleterm", "quickfix" }
      })
    end,
  },

  -- Bufferline: Shows open buffers in a tab-like interface
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- "buffers" or "tabs"
          numbers = "none", -- "none" | "ordinal" | "buffer_id" | "both" | function
          close_command = "bdelete! %d", -- can be a string | function
          right_mouse_command = "bdelete! %d", -- can be a string | function
          left_mouse_command = "buffer %d", -- can be a string | function
          middle_mouse_command = nil, -- can be a string | function
          indicator = {
            icon = "▎", -- this should be omitted if indicator style is not 'icon'
            style = "icon", -- 'icon' | 'underline' | 'none'
          },
          buffer_close_icon = "",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
          truncate_names = true, -- whether or not tab names should be truncated
          tab_size = 21,
          diagnostics = "nvim_lsp", -- false | "nvim_lsp" | "coc"
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            }
          },
          color_icons = true, -- whether or not to add the filetype icon highlights
          show_buffer_icons = true, -- disable filetype icons for buffers
          show_buffer_close_icons = true,
          show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
          separator_style = "thin", -- "slant" | "thick" | "thin" | { 'any', 'any' }
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = {"close"}
          },
        }
      })
    end,
  },

  -- Indent guides: Shows vertical lines for indentation levels
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    config = function()
      require("indent_blankline").setup({
        char = "│",
        show_trailing_blankline_indent = false,
        show_first_indent_level = true,
        use_treesitter = true,
        show_current_context = true,
        show_current_context_start = false,
        filetype_exclude = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      })
    end,
  },

  -- File explorer: NvimTree for navigating project structure
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
      { "<leader>o", "<cmd>NvimTreeFocus<cr>", desc = "Focus file explorer" },
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          adaptive_size = false,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "",
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
              folder = {
                arrow_open = "",
                arrow_closed = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        actions = {
          open_file = {
            window_picker = {
              enable = false,
            },
            resize_window = true,
          },
        },
      })
    end,
  },

  -- UI improvements: Better UI for inputs and selections
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          default_prompt = "Input:",
          prompt_align = "left",
          insert_only = true,
          border = "rounded",
          relative = "cursor",
          prefer_width = 40,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          win_options = {
            winblend = 0,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf", "builtin" },
          telescope = require('telescope.themes').get_dropdown(),
          builtin = {
            border = "rounded",
            relative = "editor",
            win_options = {
              winblend = 0,
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            },
          },
        },
      })
    end,
  },

  -- Notifications: Enhanced notification system
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        stages = "fade",
        timeout = 3000,
        max_width = 80,
        max_height = 20,
        background_colour = "#000000",
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
      })
      
      vim.notify = require("notify")
    end,
  },
}

