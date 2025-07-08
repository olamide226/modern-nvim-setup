-- plugins/test-reporter.lua - Enhanced test visualization and reporting

return {
  -- This plugin extends neotest with enhanced reporting capabilities
  {
    "nvim-neotest/neotest",
    dependencies = {
      -- Additional dependencies for UI
      "MunifTanjim/nui.nvim",
    },
    keys = {
      -- Report-specific keymaps
      { "<leader>tr", function() require("user.test-reporter").show_results() end, desc = "Show Test Results" },
      { "<leader>tR", function() require("user.test-reporter").export_results() end, desc = "Export Test Results" },
      { "<leader>tT", function() require("user.test-reporter").show_summary() end, desc = "Test Summary" },
    },
    config = function()
      -- Create a namespace for test reporter
      local test_reporter = {}
      _G.test_reporter = test_reporter
      
      -- Initialize state
      test_reporter.state = {
        current_run = {
          total = 0,
          passed = 0,
          failed = 0,
          skipped = 0,
          start_time = nil,
          end_time = nil,
          tests = {},
        },
        history = {},
      }
      
      -- Reset current run state
      function test_reporter.reset_run()
        test_reporter.state.current_run = {
          total = 0,
          passed = 0,
          failed = 0,
          skipped = 0,
          start_time = os.time(),
          end_time = nil,
          tests = {},
        }
      end
      
      -- Create a floating window for displaying test results
      function test_reporter.create_floating_win(title, width, height)
        -- Create a centered floating window
        local ui = require("nui.popup")
        local win = ui({
          enter = true,
          focusable = true,
          border = {
            style = "rounded",
            text = {
              top = " " .. title .. " ",
              top_align = "center",
            },
          },
          position = "50%",
          size = {
            width = width or "80%",
            height = height or "60%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })
        
        -- Close with q
        win:map("n", "q", function()
          win:unmount()
        end, { noremap = true })
        
        return win
      end
      
      -- Format time duration
      function test_reporter.format_duration(seconds)
        if seconds < 1 then
          return string.format("%.0f ms", seconds * 1000)
        elseif seconds < 60 then
          return string.format("%.2f s", seconds)
        else
          local minutes = math.floor(seconds / 60)
          local remaining_seconds = seconds % 60
          return string.format("%d min %d s", minutes, remaining_seconds)
        end
      end
      
      -- Display test results in a floating window
      function test_reporter.show_results()
        local run = test_reporter.state.current_run
        if run.total == 0 then
          vim.notify("No test results available", vim.log.levels.INFO)
          return
        end
        
        local win = test_reporter.create_floating_win("Test Results", 80, 20)
        win:mount()
        
        -- Prepare results output
        local results = {
          "Test Results",
          string.rep("=", 50),
          "",
          string.format("Total Tests: %d", run.total),
          string.format("Passed:      %d", run.passed),
          string.format("Failed:      %d", run.failed),
          string.format("Skipped:     %d", run.skipped),
        }
        
        if run.start_time and run.end_time then
          local duration = os.difftime(run.end_time, run.start_time)
          table.insert(results, string.format("Duration:    %s", test_reporter.format_duration(duration)))
        end
        
        table.insert(results, "")
        table.insert(results, "Failed Tests:")
        table.insert(results, string.rep("-", 50))
        
        -- Add details for failed tests
        local has_failures = false
        for _, test in ipairs(run.tests) do
          if test.status == "fail" or test.status == "failed" then
            has_failures = true
            table.insert(results, "")
            table.insert(results, string.format("Test:  %s", test.name))
            table.insert(results, string.format("File:  %s", test.file))
            table.insert(results, string.format("Line:  %d", test.line or 0))
            
            if test.message then
              table.insert(results, "Error: " .. test.message)
            end
          end
        end
        
        if not has_failures then
          table.insert(results, "")
          table.insert(results, "No failed tests!")
        end
        
        -- Set the buffer content
        vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, results)
        
        -- Make buffer read-only
        vim.api.nvim_buf_set_option(win.bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(win.bufnr, "readonly", true)
        
        -- Set up syntax highlighting for the results
        vim.cmd("highlight TestResultsHeader gui=bold")
        vim.cmd("highlight TestResultsPass guifg=#A3BE8C")
        vim.cmd("highlight TestResultsFail guifg=#BF616A")
        vim.cmd("highlight TestResultsSkip guifg=#EBCB8B")
        
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsHeader", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsHeader", 3, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsPass", 4, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsFail", 5, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsSkip", 6, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, 0, "TestResultsHeader", 10, 0, -1)
      end
      
      -- Export test results to a file
      function test_reporter.export_results()
        local run = test_reporter.state.current_run
        if run.total == 0 then
          vim.notify("No test results to export", vim.log.levels.INFO)
          return
        end
        
        -- Create a directory for reports if it doesn't exist
        local reports_dir = vim.fn.getcwd() .. "/test-reports"
        vim.fn.mkdir(reports_dir, "p")
        
        local timestamp = os.date("%Y%m%d-%H%M%S")
        local report_file = string.format("%s/test-report-%s.html", reports_dir, timestamp)
        
        local file = io.open(report_file, "w")
        if not file then
          vim.notify("Failed to create report file: " .. report_file, vim.log.levels.ERROR)
          return
        end
        
        -- Write HTML report header
        file:write([[
        <!DOCTYPE html>
        <html>
        <head>
          <title>Test Results</title>
          <style>
            body { 
              font-family: Arial, sans-serif; 
              line-height: 1.6;
              margin: 0;
              padding: 20px;
              color: #333;
            }
            .container {
              max-width: 1000px;
              margin: 0 auto;
            }
            h1 { 
              color: #2c3e50;
              border-bottom: 2px solid #eee;
              padding-bottom: 10px;
            }
            .summary {
              background: #f8f9fa;
              padding: 15px;
              border-radius: 5px;
              margin-bottom: 20px;
            }
            .passed { color: #27ae60; }
            .failed { color: #e74c3c; }
            .skipped { color: #f39c12; }
            .test-details {
              margin-top: 30px;
            }
            .test {
              margin-bottom: 15px;
              padding: 15px;
              border-radius: 5px;
            }
            .test-passed { background-color: #e8f5e9; }
            .test-failed { background-color: #ffebee; }
            .test-skipped { background-color: #fff8e1; }
            .error-message {
              background: #fafafa;
              padding: 10px;
              border-left: 3px solid #e74c3c;
              font-family: monospace;
              white-space: pre-wrap;
            }
            .timestamp {
              color: #7f8c8d;
              font-size: 0.9em;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>Test Results</h1>
            <div class="summary">
        ]])
        
        -- Write summary
        local duration = run.end_time and os.difftime(run.end_time, run.start_time) or 0
        file:write(string.format([[
              <p><strong>Date:</strong> %s</p>
              <p><strong>Total Tests:</strong> %d</p>
              <p><strong class="passed">Passed:</strong> %d</p>
              <p><strong class="failed">Failed:</strong> %d</p>
              <p><strong class="skipped">Skipped:</strong> %d</p>
              <p><strong>Duration:</strong> %s</p>
            </div>
        ]], 
          os.date("%Y-%m-%d %H:%M:%S", run.start_time),
          run.total,
          run.passed,
          run.failed,
          run.skipped,
          test_reporter.format_duration(duration)
        ))
        
        -- Write test details section
        file:write([[
            <div class="test-details">
              <h2>Test Details</h2>
        ]])
        
        -- Write each test result
        for _, test in ipairs(run.tests) do
          local status_class = "test-" .. (test.status == "pass" and "passed" or test.status == "fail" and "failed" or "skipped")
          
          file:write(string.format([[
              <div class="test %s">
                <h3>%s</h3>
                <p><strong>File:</strong> %s</p>
                <p><strong>Line:</strong> %d</p>
                <p><strong>Status:</strong> %s</p>
          ]],
            status_class,
            test.name,
            test.file,
            test.line or 0,
            test.status
          ))
          
          if test.message and test.status == "fail" then
            file:write(string.format([[
                <div class="error-message">%s</div>
            ]], test.message))
          end
          
          file:write("</div>\n")
        end
        
        -- Write footer
        file:write([[
            </div>
          </div>
        </body>
        </html>
        ]])
        
        file:close()
        vim.notify("Test report exported to: " .. report_file, vim.log.levels.INFO)
      end
      
      -- Show test summary in a compact format
      function test_reporter.show_summary()
        local run = test_reporter.state.current_run
        if run.total == 0 then
          vim.notify("No test results available", vim.log.levels.INFO)
          return
        end
        
        local summary = string.format(
          "Tests: %d total, %d passed, %d failed, %d skipped",
          run.total, run.passed, run.failed, run.skipped
        )
        
        if run.start_time and run.end_time then
          local duration = os.difftime(run.end_time, run.start_time)
          summary = summary .. " (Duration: " .. test_reporter.format_duration(duration) .. ")"
        end
        
        if run.failed > 0 then
          vim.notify(summary, vim.log.levels.ERROR)
        elseif run.skipped > 0 then
          vim.notify(summary, vim.log.levels.WARN)
        else
          vim.notify(summary, vim.log.levels.INFO)
        end
      end
      
      -- Hook into neotest to capture results
      local neotest = require("neotest")
      
      -- Start tracking when test run begins
      neotest.listeners.register({
        run_start = function()
          test_reporter.reset_run()
        end,
        
        -- Process results when tests finish
        run_complete = function()
          -- Mark run as completed
          test_reporter.state.current_run.end_time = os.time()
          
          -- Save to history
          table.insert(test_reporter.state.history, vim.deepcopy(test_reporter.state.current_run))
          
          -- Limit history size
          if #test_reporter.state.history > 10 then
            table.remove(test_reporter.state.history, 1)
          end
          
          -- Show brief summary
          test_reporter.show_summary()
        end,
        
        -- Track individual test results
        test_start = function(test_path)
          -- Record test start
        end,
        
        -- Process results when a test finishes
        test_complete = function(test_path, result)
          if not result then return end
          
          local run = test_reporter.state.current_run
          run.total = run.total + 1
          
          -- Extract test info
          local status = result.status or "unknown"
          if status == "passed" then
            status = "pass"
            run.passed = run.passed + 1
          elseif status == "failed" then
            status = "fail"
            run.failed = run.failed + 1
          elseif status == "skipped" then
            run.skipped = run.skipped + 1
          end
          
          -- Extract error message if present
          local message = nil
          if result.errors and #result.errors > 0 then
            message = table.concat(result.errors, "\n")
          end
          
          -- Extract file path and line number
          local file = test_path
          if type(file) == "string" and vim.fn.filereadable(file) == 1 then
            file = vim.fn.fnamemodify(file, ":~:.")
          end
          
          -- Get test name from position
          local name = result.name or vim.fn.fnamemodify(file, ":t")
          
          -- Add to current run results
          table.insert(run.tests, {
            name = name,
            file = file,
            line = result.line,
            status = status,
            message = message,
          })
        end,
      })
      
      -- Make reporter available globally
      package.loaded["user.test-reporter"] = test_reporter
      
      return test_reporter
    end,
  }
}

