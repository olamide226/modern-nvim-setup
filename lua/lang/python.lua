-- lang/python.lua - Python development configuration

local M = {}

------------------------------------------
-- Python LSP Configuration
------------------------------------------
function M.setup_lsp()
  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Pyright setup
  lspconfig.pyright.setup({
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          diagnosticMode = "workspace",
          inlayHints = {
            variableTypes = true,
            functionReturnTypes = true,
          },
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticSeverityOverrides = {
            reportGeneralTypeIssues = "warning",
            reportOptionalMemberAccess = "warning",
            reportOptionalSubscript = "warning",
            reportPrivateImportUsage = "warning",
          },
        },
      },
    },
    before_init = function(_, config)
      -- Try to use the virtual environment's Python
      local venv_path = vim.fn.getenv("VIRTUAL_ENV")
      if venv_path then
        config.settings.python.pythonPath = venv_path .. "/bin/python"
      end
    end,
  })
end

------------------------------------------
-- Python Debugging Configuration
------------------------------------------
function M.setup_dap()
  local dap = require('dap')
  local dap_python = require('dap-python')

  -- Set up Python DAP
  dap_python.setup('~/.virtualenvs/debugpy/bin/python')
  dap_python.test_runner = 'pytest'

  -- Configure test strategies
  dap_python.resolve_python = function()
    return vim.fn.getenv("VIRTUAL_ENV") and
      vim.fn.getenv("VIRTUAL_ENV") .. "/bin/python" or
      vim.fn.exepath("python3") or
      vim.fn.exepath("python")
  end
end

------------------------------------------
-- Python Formatting and Linting
------------------------------------------
function M.setup_formatting()
  local null_ls = require("null-ls")
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics

  null_ls.setup({
    sources = {
      -- Formatting
      formatting.black.with({
        extra_args = {"--fast", "--line-length", "88"}
      }),
      formatting.isort.with({
        extra_args = {"--profile", "black"}
      }),

      -- Linting
      diagnostics.pylint.with({
        diagnostics_postprocess = function(diagnostic)
          diagnostic.severity = vim.diagnostic.severity.WARN
        end,
        extra_args = {
          "--rcfile=" .. vim.fn.expand("~/.pylintrc"),
          "--score=no",
        },
      }),
      diagnostics.mypy.with({
        extra_args = {"--ignore-missing-imports"}
      }),
    },
  })
end

------------------------------------------
-- Virtual Environment Management
------------------------------------------
function M.setup_venv()
  require("venv-selector").setup({
    name = ".venv",
    auto_refresh = true,
    search = true,
    search_paths = {
      ".",
      "~/.virtualenvs",
    },
    parents = 0,
    path_to_python = function(venv)
      if vim.fn.has("win32") == 1 then
        return venv .. "/Scripts/python.exe"
      end
      return venv .. "/bin/python"
    end,
    notify_user_on_activate = true,
  })
end

------------------------------------------
-- Python-specific Commands
------------------------------------------
function M.setup_commands()
  -- Create user commands
  vim.api.nvim_create_user_command("PythonTest", function()
    require("dap-python").test_method()
  end, { desc = "Run Python test under cursor" })

  vim.api.nvim_create_user_command("PythonTestClass", function()
    require("dap-python").test_class()
  end, { desc = "Run Python class tests" })

  vim.api.nvim_create_user_command("PythonDebug", function()
    require("dap-python").debug_selection()
  end, { desc = "Debug Python selection" })
end

------------------------------------------
-- Python-specific Autocommands
------------------------------------------
function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("PythonConfig", { clear = true })

  -- Auto-format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = "*.py",
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
    desc = "Format Python files on save",
  })

  -- Set Python-specific options
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = function()
      -- Set Python-specific options
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.textwidth = 88
      vim.opt_local.colorcolumn = "88"
      vim.opt_local.foldmethod = "indent"
      vim.opt_local.foldlevel = 99
    end,
    desc = "Set Python file options",
  })
end

------------------------------------------
-- Initialize Python Configuration
------------------------------------------
function M.setup()
  -- Ensure required plugins are available
  local has_lspconfig = pcall(require, "lspconfig")
  local has_dap = pcall(require, "dap")
  local has_dap_python = pcall(require, "dap-python")
  local has_null_ls = pcall(require, "null-ls")
  local has_venv = pcall(require, "venv-selector")

  if has_lspconfig then
    M.setup_lsp()
  end

  if has_dap and has_dap_python then
    M.setup_dap()
  end

  if has_null_ls then
    M.setup_formatting()
  end

  if has_venv then
    M.setup_venv()
  end

  M.setup_commands()
  M.setup_autocmds()
end

return M

