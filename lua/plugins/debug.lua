-- plugins/debug.lua - Debugging support for Python and TypeScript using nvim-dap

return {
  -- DAP (Debug Adapter Protocol) setup
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Debugger UI
      {
        "rcarriga/nvim-dap-ui",
        keys = {
          { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
        },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          
          -- Auto open/close UI based on DAP events
          dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
        end,
      },
      
      -- Virtual text for inline debug information
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          virtualline_text = {
            text = function() return "←" end,
            highlight = "Keyword",
          },
          all_frames = true,
        },
      },
      
      -- Debugging configuration for Python
      {
        "mfussenegger/nvim-dap-python",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
          -- Simple approach: use Mason's standard path for debugpy
          local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          
          -- Check if Mason's debugpy exists, otherwise use system python
          if vim.fn.executable(mason_path) == 1 then
            require("dap-python").setup(mason_path)
          else
            -- Fallback to system python (assumes debugpy is installed via pip)
            require("dap-python").setup("python")
          end
        end,
      },
      
      -- JS/TS debugging support
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          require("dap-vscode-js").setup({
            debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
            adapters = { "pwa-node", "pwa-chrome", "node-terminal", "pwa-extensionHost" },
          })
          
          for _, lang in ipairs({ "javascript", "typescript" }) do
            require("dap").configurations[lang] = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch File",
                program = "${file}",
                cwd = "${workspaceFolder}",
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal",
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach to Process",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
                sourceMaps = true,
              },
              {
                type = "pwa-chrome",
                request = "launch",
                name = "Launch Chrome",
                url = "http://localhost:3000",
                webRoot = "${workspaceFolder}",
                userDataDir = "${workspaceFolder}/.vscode/chrome",
                sourceMaps = true,
                protocol = "inspector",
                port = 9222,
                runtimeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
              },
            }
          end
        end,
      },
    },
    keys = {
      -- Basic DAP operations
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate Debugging" },
      
      -- Python specific
      { "<leader>dpt", function() require("dap-python").test_method() end, desc = "Test Python Method" },
      { "<leader>dpc", function() require("dap-python").test_class() end, desc = "Test Python Class" },
      { "<leader>dps", function() require("dap-python").debug_selection() end, desc = "Debug Selection" },
    },
    config = function()
      local lo = {
        Stopped = { text = "—", texthl = "DiagnosticWarn", linehl = "", numhl = "" },
        Breakpoint = { text = "•", texthl = "DiagnosticSignError", linehl = "", numhl = "DiagnosticSignHint" },
      }
      for name, sign in pairs(lo) do
        vim.fn.sign_define("Dap" .. name, { text = sign.text, texthl = sign.texthl, linehl = sign.linehl, numhl = sign.numhl })
      end
    end,
  },
  
  -- Use Mason to install DAP adapters
  {
    "williamboman/mason.nvim",
    ensure_installed = { "debugpy", "js-debug-adapter" },
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup {
        ensure_installed = { "python", "js", "chrome" },
      }
    end,
  },
}

