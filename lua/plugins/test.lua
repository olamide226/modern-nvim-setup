-- plugins/test.lua - Test runner configuration for Python and TypeScript with coverage support

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      -- Python test adapter
      "nvim-neotest/neotest-python",
      -- JavaScript/TypeScript test adapters
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      -- Coverage visualization
      {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          require("coverage").setup({
            signs = {
              covered = { hl = "CoverageCovered", text = "│" },
              uncovered = { hl = "CoverageUncovered", text = "│" },
              partial = { hl = "CoveragePartial", text = "│" },
            },
            summary = {
              min_coverage = 80.0,
            },
            lang = {
              python = {
                coverage_file = ".coverage",
                coverage_command = "coverage json --fail-under=0",
              },
              javascript = {
                coverage_file = "coverage/coverage-final.json",
              },
              typescript = {
                coverage_file = "coverage/coverage-final.json",
              },
            },
            auto_reload = true,
            load_coverage_cb = function(ftype)
              vim.notify("Loaded " .. ftype .. " coverage")
            end,
          })
          
          -- Set up highlight groups for coverage markers
          vim.api.nvim_set_hl(0, "CoverageCovered", { fg = "#50FA7B" }) -- Green
          vim.api.nvim_set_hl(0, "CoverageUncovered", { fg = "#FF5555" }) -- Red
          vim.api.nvim_set_hl(0, "CoveragePartial", { fg = "#F1FA8C" }) -- Yellow
        end
      },
    },
    keys = {
      -- Standard test operations
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run Current File" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest Test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last Test" },
      { "<leader>tL", function() require("neotest").run.run_last({ strategy = "dap" }) end, desc = "Debug Last Test" },
      { "<leader>tx", function() require("neotest").run.stop() end, desc = "Stop Test Run" },
      { "<leader>ta", function() require("neotest").run.attach() end, desc = "Attach to Test Process" },
      { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Jump to Previous Failed Test" },
      { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Jump to Next Failed Test" },
      
      -- Coverage-specific operations
      { "<leader>tc", function()
          -- Run test with coverage
          local filetype = vim.bo.filetype
          if filetype == "python" then
            -- For Python tests
            require("neotest").run.run({
              extra_args = {"--cov", "--cov-report=xml", "--cov-report=term"},
            })
            -- Load coverage after test run
            vim.defer_fn(function()
              require("coverage").load(true)
            end, 2000)
          elseif filetype == "javascript" or filetype == "typescript" or filetype == "typescriptreact" or filetype == "javascriptreact" then
            -- For JS/TS tests
            require("neotest").run.run({
              extra_args = {"--coverage"},
            })
            -- Load coverage after test run
            vim.defer_fn(function()
              require("coverage").load(true)
            end, 2000)
          else
            vim.notify("Coverage not supported for " .. filetype, vim.log.levels.WARN)
          end
        end,
        desc = "Run Test with Coverage"
      },
      { "<leader>tC", function() require("coverage").toggle() end, desc = "Toggle Coverage" },
      { "<leader>tS", function() require("coverage").summary() end, desc = "Show Coverage Summary" },
      { "<leader>tl", function() require("coverage").load() end, desc = "Load Coverage Data" },
      { "<leader>tp", function() require("coverage").clear() end, desc = "Clear Coverage" },
    },
    config = function()
      -- Get path to virtual environment Python interpreter
      local get_python_path = function()
        -- Try to find a Python virtual environment in standard locations
        local venv_paths = {
          vim.fn.getcwd() .. "/.venv/bin/python",
          vim.fn.getcwd() .. "/venv/bin/python",
          vim.fn.expand("~/.virtualenvs/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/bin/python"),
        }
        
        for _, path in ipairs(venv_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end
        
        -- Fall back to system Python
        local python_paths = { "python3", "python" }
        for _, path in ipairs(python_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end
        
        return nil
      end
      
      -- Function to check if a command is available
      local function is_command_available(cmd)
        local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          return result and result ~= ""
        end
        return false
      end
      
      -- Setup hooks for coverage integration
      local function setup_coverage_hooks()
        -- After test run, load coverage data
        vim.api.nvim_create_autocmd("User", {
          pattern = "NeotestRunComplete",
          callback = function()
            -- Wait a bit for coverage files to be written
            vim.defer_fn(function()
              -- Try to load coverage data based on filetype
              local ft = vim.bo.filetype
              if ft == "python" or ft == "javascript" or ft == "typescript" or ft == "typescriptreact" or ft == "javascriptreact" then
                require("coverage").load(true)
              end
            end, 1000)
          end,
        })
      end
      
      -- Call setup_coverage_hooks when Neovim is ready
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = setup_coverage_hooks,
        once = true,
      })
      
      require("neotest").setup({
        adapters = {
          -- Python test adapter configuration
          require("neotest-python")({
            -- Use pytest as the default test runner
            runner = "pytest",
            
            -- Arguments for pytest - updated to support coverage
            args = function()
              local args = {"--verbose", "--color=yes"}
              
              -- Add coverage args if pytest-cov is installed
              if is_command_available("python -m pytest --cov --help") then
                table.insert(args, "--cov")
                table.insert(args, "--cov-report=xml")
                table.insert(args, "--cov-report=json")
              end
              
              return args
            end,
            
            -- Use virtual environment if available
            python = get_python_path,
            
            -- Test discovery settings
            discovery = {
              enabled = true,
              filter_dir = function(name)
                -- Skip directories that typically don't contain tests
                return not vim.tbl_contains({
                  ".git",
                  "node_modules",
                  "venv",
                  ".venv",
                  "__pycache__",
                  ".pytest_cache",
                  ".mypy_cache",
                  "coverage",
                  "htmlcov",
                }, name)
              end,
            },
          }),
          
          -- Jest adapter for JavaScript/TypeScript
          require("neotest-jest")({
            -- Command to run Jest with coverage support
            jestCommand = function()
              -- Check if package.json has coverage configuration
              local has_coverage = false
              if vim.fn.filereadable("package.json") == 1 then
                local package_json = vim.fn.system("cat package.json")
                has_coverage = package_json:find('"coverage"') ~= nil
              end
              
              if has_coverage then
                return "npm test -- --coverage"
              else
                return "npm test --"
              end
            end,
            
            -- Automatically find Jest config file
            jestConfigFile = function()
              local possible_config_files = {
                "jest.config.js",
                "jest.config.ts",
                "jest.config.mjs",
                "jest.config.cjs",
              }
              
              for _, file in ipairs(possible_config_files) do
                if vim.fn.filereadable(file) == 1 then
                  return file
                end
              end
              
              -- Check for Jest configuration in package.json
              if vim.fn.filereadable("package.json") == 1 then
                return "package.json"
              end
              
              return nil
            end,
            
            -- Environment variables
            env = {
              CI = true,
              JEST_JUNIT_OUTPUT_DIR = "coverage/junit",
            },
            
            -- Use project root directory
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
          
          -- Vitest adapter for JavaScript/TypeScript
          require("neotest-vitest")({
            -- Command to run Vitest with coverage
            vitestCommand = function()
              -- Check if vitest.config.js has coverage configuration
              local has_coverage = false
              local config_files = {
                "vitest.config.js",
                "vitest.config.ts",
                "vite.config.js",
                "vite.config.ts",
              }
              
              for _, file in ipairs(config_files) do
                if vim.fn.filereadable(file) == 1 then
                  local config_content = vim.fn.system("cat " .. file)
                  if config_content:find("coverage") then
                    has_coverage = true
                    break
                  end
                end
              end
              
              if has_coverage then
                return "npx vitest --coverage"
              else
                return "npx vitest"
              end
            end,
            
            -- Filter to identify test files
            filetypes = { "javascript", "typescript", "jsx", "tsx" },
          }),
        },
        
        -- UI configuration
        icons = {
          -- Markers
          expanded = "▾",
          collapsed = "▸",
          passed = "✓",
          running = "⟳",
          failed = "✗",
          unknown = "?",
          skipped = "⏭",
        },
        
        -- General settings
        discovery = {
          enabled = true,
        },
        
        -- Summary window configuration
        summary = {
          enabled = true,
          follow = true,
          mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            run = "r",
            debug = "d",
            stop = "s",
            attach = "a",
            output = "o",
            jumpto = "i",
            next_failed = "]f",
            prev_failed = "[f",
          },
        },
        
        -- Status handling
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        
        -- Test output configuration
        output = {
          enabled = true,
          open_on_run = true,
        },
        
        -- Quick fix integration
        quickfix = {
          enabled = true,
          open = function()
            vim.cmd("copen")
          end,
        },
        
        -- Integration with DAP for debugging tests
        consumers = {
          -- DAP integration
          dap = function(_, _)
            require("dap").run({
              type = "neotest",
              request = "attach",
              name = "Neotest Debugger",
            })
          end,
          
          -- Coverage integration
          coverage = function()
            -- This consumer will be called after tests run
            -- We handle the coverage loading via autocmd instead
            -- to ensure files are properly written before loading
          end,
        },
        
        -- Default running strategy
        default_strategy = "integrated",
        
        -- Diagnostic handling
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },
        
        -- Run options that apply to all adapters
        run = {
          -- Enable saving before running tests
          enabled = true,
        },
      })
      
      -- Commands for managing code coverage
      vim.api.nvim_create_user_command("CoverageLoad", function()
        require("coverage").load()
      end, { desc = "Load code coverage data" })
      
      vim.api.nvim_create_user_command("CoverageToggle", function()
        require("coverage").toggle()
      end, { desc = "Toggle code coverage display" })
      
      vim.api.nvim_create_user_command("CoverageSummary", function()
        require("coverage").summary()
      end, { desc = "Show code coverage summary" })
      
      vim.api.nvim_create_user_command("CoverageClear", function()
        require("coverage").clear()
      end, { desc = "Clear code coverage display" })
      
      -- Setup additional coverage key mappings via which-key if available
      vim.defer_fn(function()
        local ok, wk = pcall(require, "which-key")
        if ok then
          wk.register({
            ["<leader>t"] = {
              c = { "Run with Coverage" },
              C = { "Toggle Coverage" },
              S = { "Coverage Summary" },
            },
          })
        end
      end, 1000)
    end,
  },
}

