-- plugins/test-analytics.lua - Test analytics and trends analysis

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>ta", function() require("test-analytics").show_trends() end, desc = "Show Test Trends" },
      { "<leader>tF", function() require("test-analytics").show_flaky_tests() end, desc = "Show Flaky Tests" },
      { "<leader>tP", function() require("test-analytics").show_failure_patterns() end, desc = "Show Failure Patterns" },
      { "<leader>tD", function() require("test-analytics").show_dashboard() end, desc = "Test Analytics Dashboard" },
    },
    config = function()
      -- Create analytics module
      local analytics = {}
      
      -- Storage for test runs
      analytics.history = {
        runs = {},
        max_runs = 100,
        files = {},
        tests = {},
      }
      
      -- Metrics tracking
      analytics.metrics = {
        total_runs = 0,
        total_duration = 0,
        pass_rate = 0,
        recent_pass_rate = 0,
        flaky_tests = {},
        failure_patterns = {},
        run_frequency = {},
      }
      
      -- Add test run to history
      function analytics.record_run(run_data)
        -- Skip empty runs
        if not run_data or not run_data.tests or #run_data.tests == 0 then
          return
        end
        
        -- Add timestamp if not present
        run_data.timestamp = run_data.timestamp or os.time()
        
        -- Add to history
        table.insert(analytics.history.runs, vim.deepcopy(run_data))
        
        -- Trim history if needed
        if #analytics.history.runs > analytics.history.max_runs then
          table.remove(analytics.history.runs, 1)
        end
        
        -- Update metrics
        analytics.update_metrics()
        
        -- Process tests
        for _, test in ipairs(run_data.tests) do
          analytics.process_test(test)
        end
        
        -- Save to disk
        analytics.save_history()
      end
      
      -- Process individual test results
      function analytics.process_test(test)
        local test_id = test.file .. ":" .. (test.line or 0)
        
        -- Initialize test record if needed
        if not analytics.history.tests[test_id] then
          analytics.history.tests[test_id] = {
            name = test.name,
            file = test.file,
            line = test.line,
            runs = 0,
            passes = 0,
            failures = 0,
            history = {},
            last_status = nil,
            flaky = false,
            failure_messages = {},
          }
        end
        
        local record = analytics.history.tests[test_id]
        
        -- Update stats
        record.runs = record.runs + 1
        if test.status == "pass" then
          record.passes = record.passes + 1
        elseif test.status == "fail" then
          record.failures = record.failures + 1
          
          -- Record failure message
          if test.message then
            -- Extract pattern
            local pattern = analytics.extract_failure_pattern(test.message)
            
            -- Record in test
            record.failure_messages[pattern] = (record.failure_messages[pattern] or 0) + 1
            
            -- Record in global patterns
            analytics.metrics.failure_patterns[pattern] = (analytics.metrics.failure_patterns[pattern] or 0) + 1
          end
        end
        
        -- Check for flakiness
        if record.last_status and record.last_status ~= test.status then
          record.flaky = true
          analytics.metrics.flaky_tests[test_id] = record
        end
        
        -- Save status
        record.last_status = test.status
        
        -- Add to history
        table.insert(record.history, {
          timestamp = os.time(),
          status = test.status,
          message = test.message,
        })
        
        -- Limit history size
        if #record.history > 20 then
          table.remove(record.history, 1)
        end
        
        -- Track per-file stats
        local file = test.file
        if not analytics.history.files[file] then
          analytics.history.files[file] = {
            tests = 0,
            passes = 0,
            failures = 0,
            last_run = 0,
          }
        end
        
        local file_record = analytics.history.files[file]
        file_record.tests = file_record.tests + 1
        if test.status == "pass" then
          file_record.passes = file_record.passes + 1
        elseif test.status == "fail" then
          file_record.failures = file_record.failures + 1
        end
        file_record.last_run = os.time()
      end
      
      -- Extract generalized pattern from failure message
      function analytics.extract_failure_pattern(message)
        if not message then return "Unknown error" end
        
        -- First 100 chars only, to avoid huge patterns
        message = message:sub(1, 100)
        
        -- Replace specifics with placeholders
        local pattern = message
          :gsub("%d+", "N")
          :gsub("'[^']+'", "'X'")
          :gsub('"[^"]+"', '"X"')
          :gsub("%.%.%.", "...")
          :gsub("\n", " ")
          
        return pattern
      end
      
      -- Update overall metrics
      function analytics.update_metrics()
        local metrics = analytics.metrics
        local runs = analytics.history.runs
        
        metrics.total_runs = #runs
        metrics.total_duration = 0
        
        local pass_total = 0
        local recent_pass_total = 0
        local recent_count = 0
        
        -- Process runs
        for i, run in ipairs(runs) do
          -- Duration
          if run.start_time and run.end_time then
            metrics.total_duration = metrics.total_duration + os.difftime(run.end_time, run.start_time)
          end
          
          -- Pass rate
          if run.total > 0 then
            local pass_rate = run.passed / run.total
            pass_total = pass_total + pass_rate
            
            -- Recent runs (last 10)
            if i > #runs - 10 then
              recent_pass_total = recent_pass_total + pass_rate
              recent_count = recent_count + 1
            end
          end
          
          -- Track run frequency
          local day = os.date("%Y-%m-%d", run.timestamp)
          metrics.run_frequency[day] = (metrics.run_frequency[day] or 0) + 1
        end
        
        -- Calculate averages
        metrics.pass_rate = #runs > 0 and (pass_total / #runs) * 100 or 0
        metrics.recent_pass_rate = recent_count > 0 and (recent_pass_total / recent_count) * 100 or 0
      end
      
      -- Save history to disk
      function analytics.save_history()
        -- Create directory if it doesn't exist
        local history_dir = vim.fn.stdpath("data") .. "/test-analytics"
        vim.fn.mkdir(history_dir, "p")
        
        -- Create minimal history for serialization
        local save_data = {
          metrics = analytics.metrics,
          tests = {},
          timestamp = os.time(),
        }
        
        -- Only save flaky tests and recent failures
        for id, test in pairs(analytics.metrics.flaky_tests) do
          save_data.tests[id] = {
            name = test.name,
            file = test.file,
            line = test.line,
            passes = test.passes,
            failures = test.failures,
            flaky = true,
          }
        end
        
        -- Serialize to JSON
        local ok, json_str = pcall(vim.fn.json_encode, save_data)
        if ok then
          local file = io.open(history_dir .. "/history.json", "w")
          if file then
            file:write(json_str)
            file:close()
          end
        end
      end
      
      -- Load history from disk
      function analytics.load_history()
        local history_file = vim.fn.stdpath("data") .. "/test-analytics/history.json"
        if vim.fn.filereadable(history_file) == 0 then
          return
        end
        
        -- Read file
        local file = io.open(history_file, "r")
        if not file then return end
        
        local content = file:read("*a")
        file:close()
        
        -- Parse JSON
        local ok, data = pcall(vim.fn.json_decode, content)
        if ok and data then
          -- Restore metrics
          if data.metrics then
            analytics.metrics = data.metrics
          end
          
          -- Restore tests
          if data.tests then
            for id, test in pairs(data.tests) do
              analytics.history.tests[id] = test
              if test.flaky then
                analytics.metrics.flaky_tests[id] = test
              end
            end
          end
        end
      end
      
      -- Format a trend indicator
      function analytics.trend_indicator(current, previous)
        if not previous then return "  " end
        
        if current > previous * 1.05 then
          return "↗️ "  -- Significant increase
        elseif current < previous * 0.95 then
          return "↘️ "  -- Significant decrease
        else
          return "→ "  -- Stable
        end
      end
      
      -- Show trends dashboard
      function analytics.show_trends()
        -- Create window
        local win = require("nui.popup")({
          enter = true,
          focusable = true,
          border = {
            style = "rounded",
            text = {
              top = " Test Trends Analysis ",
              top_align = "center",
            },
          },
          position = "50%",
          size = {
            width = "80%",
            height = "60%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })
        
        win:mount()
        
        -- Prepare data
        local metrics = analytics.metrics
        local runs = analytics.history.runs
        local pass_rates = {}
        local durations = {}
        
        -- Extract trends from last 10 runs
        local last_n = math.min(10, #runs)
        for i = #runs - last_n + 1, #runs do
          local run = runs[i]
          if run.total > 0 then
            table.insert(pass_rates, string.format("%.1f%%", (run.passed / run.total) * 100))
            
            if run.start_time and run.end_time then
              local duration = os.difftime(run.end_time, run.start_time)
              table.insert(durations, string.format("%.2fs", duration))
            else
              table.insert(durations, "?")
            end
          end
        end
        
        -- Create lines
        local lines = {
          "Test Trends Analysis",
          string.rep("=", 60),
          "",
          "Overall Metrics:",
          string.format("Total Test Runs:    %d", metrics.total_runs),
          string.format("Average Pass Rate:  %.1f%% %s", 
            metrics.pass_rate, 
            analytics.trend_indicator(metrics.recent_pass_rate, metrics.pass_rate)
          ),
          string.format("Recent Pass Rate:   %.1f%%", metrics.recent_pass_rate),
          "",
          "Recent Pass Rates (newest to oldest):",
          #pass_rates > 0 and table.concat(pass_rates, " → ") or "No data",
          "",
          "Recent Durations (newest to oldest):",
          #durations > 0 and table.concat(durations, " → ") or "No data",
          "",
          "Flaky Tests:",
          string.rep("-", 60),
        }
        
        -- Add flaky tests
        local flaky_tests = {}
        for _, test in pairs(analytics.metrics.flaky_tests) do
          table.insert(flaky_tests, test)
        end
        
        table.sort(flaky_tests, function(a, b) 
          return (a.failures / a.runs) > (b.failures / b.runs)
        end)
        
        if #flaky_tests > 0 then
          for i, test in ipairs(flaky_tests) do
            if i > 5 then break end  -- Show top 5
            
            table.insert(lines, string.format(
              "%s (%d passes, %d failures, %.1f%% pass rate)",
              test.name or "Unknown test",
              test.passes or 0,
              test.failures or 0,
              ((test.passes or 0) / (test.runs or 1)) * 100
            ))
            table.insert(lines, string.format("  File: %s:%s", test.file or "?", test.line or "?"))
            table.insert(lines, "")
          end
        else
          table.insert(lines, "No flaky tests detected")
          table.insert(lines, "")
        end
        
        -- Add failure patterns
        table.insert(lines, "Common Failure Patterns:")
        table.insert(lines, string.rep("-", 60))
        
        local patterns = {}
        for pattern, count in pairs(analytics.metrics.failure_patterns) do
          table.insert(patterns, { pattern = pattern, count = count })
        end
        
        table.sort(patterns, function(a, b) return a.count > b.count end)
        
        if #patterns > 0 then
          for i, p in ipairs(patterns) do
            if i > 5 then break end  -- Show top 5
            
            table.insert(lines, string.format(
              "Occurrences: %d\nPattern: %s\n",
              p.count,
              p.pattern
            ))
          end
        else
          table.insert(lines, "No common failure patterns found")
        end
        
        -- Set content
        vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, lines)
        
        -- Add highlighting
        local ns_id = vim.api.nvim_create_namespace("TestAnalytics")
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 3, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 8, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 11, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 14, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", #lines - (#patterns > 0 and 2 + #patterns * 3 or 3), 0, -1)
        
        -- Make buffer readonly
        vim.api.nvim_buf_set_option(win.bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(win.bufnr, "readonly", true)
        
        -- Close with q
        vim.keymap.set("n", "q", function()
          win:unmount()
        end, { buffer = win.bufnr, noremap = true })
      end
      
      -- Show list of flaky tests
      function analytics.show_flaky_tests()
        -- Create window
        local win = require("nui.popup")({
          enter = true,
          focusable = true,
          border = {
            style = "rounded",
            text = {
              top = " Flaky Tests ",
              top_align = "center",
            },
          },
          position = "50%",
          size = {
            width = "80%",
            height = "60%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })
        
        win:mount()
        
        -- Get flaky tests
        local flaky_tests = {}
        for _, test in pairs(analytics.metrics.flaky_tests) do
          table.insert(flaky_tests, test)
        end
        
        table.sort(flaky_tests, function(a, b) 
          return (a.failures / a.runs) > (b.failures / b.runs)
        end)
        
        -- Create lines
        local lines = {
          "Flaky Tests Analysis",
          string.rep("=", 60),
          "",
          string.format("Total Flaky Tests: %d", #flaky_tests),
          "",
        }
        
        if #flaky_tests > 0 then
          for _, test in ipairs(flaky_tests) do
            table.insert(lines, string.format(
              "Test: %s",
              test.name or "Unknown test"
            ))
            table.insert(lines, string.format("File: %s:%s", test.file or "?", test.line or "?"))
            table.insert(lines, string.format(
              "Stats: %d runs, %d passes, %d failures, %.1f%% pass rate",
              test.runs or 0,
              test.passes or 0,
              test.failures or 0,
              ((test.passes or 0) / (test.runs or 1)) * 100
            ))
            
            if test.history and #test.history > 0 then
              table.insert(lines, "Recent results:")
              
              local status_history = {}
              for i = #test.history, math.max(1, #test.history - 5), -1 do
                local result = test.history[i]
                table.insert(status_history, result.status == "pass" and "✅" or "❌")
              end
              
              table.insert(lines, table.concat(status_history, " "))
            end
            
            table.insert(lines, string.rep("-", 40))
          end
        else
          table.insert(lines, "No flaky tests detected")
        end
        
        -- Set content
        vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, lines)
        
        -- Add highlighting
        local ns_id = vim.api.nvim_create_namespace("TestAnalytics")
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 0, 0, -1)
        
        -- Make buffer readonly
        vim.api.nvim_buf_set_option(win.bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(win.bufnr, "readonly", true)
        
        -- Close with q
        vim.keymap.set("n", "q", function()
          win:unmount()
        end, { buffer = win.bufnr, noremap = true })
      end
      
      -- Show failure patterns
      function analytics.show_failure_patterns()
        -- Create window
        local win = require("nui.popup")({
          enter = true,
          focusable = true,
          border = {
            style = "rounded",
            text = {
              top = " Failure Patterns ",
              top_align = "center",
            },
          },
          position = "50%",
          size = {
            width = "80%",
            height = "60%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })
        
        win:mount()
        
        -- Extract patterns
        local patterns = {}
        for pattern, count in pairs(analytics.metrics.failure_patterns) do
          table.insert(patterns, { pattern = pattern, count = count })
        end
        
        table.sort(patterns, function(a, b) return a.count > b.count end)
        
        -- Create lines
        local lines = {
          "Failure Pattern Analysis",
          string.rep("=", 60),
          "",
          string.format("Total Unique Patterns: %d", #patterns),
          "",
        }
        
        if #patterns > 0 then
          for _, p in ipairs(patterns) do
            table.insert(lines, string.format("Occurrences: %d", p.count))
            table.insert(lines, string.format("Pattern: %s", p.pattern))
            
            -- Find tests with this pattern
            local tests_with_pattern = {}
            for id, test in pairs(analytics.history.tests) do
              if test.failure_messages and test.failure_messages[p.pattern] then
                table.insert(tests_with_pattern, {
                  name = test.name,
                  file = test.file,
                  count = test.failure_messages[p.pattern],
                })
              end
            end
            
            if #tests_with_pattern > 0 then
              table.insert(lines, "Affected tests:")
              
              for _, test in ipairs(tests_with_pattern) do
                table.insert(lines, string.format("- %s (%s) - %d occurrences", 
                  test.name or "Unknown",
                  test.file or "?",
                  test.count or 0
                ))
              end
            end
            
            table.insert(lines, string.rep("-", 40))
          end
        else
          table.insert(lines, "No failure patterns found")
        end
        
        -- Set content
        vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, lines)
        
        -- Add highlighting
        local ns_id = vim.api.nvim_create_namespace("TestAnalytics")
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 0, 0, -1)
        
        -- Make buffer readonly
        vim.api.nvim_buf_set_option(win.bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(win.bufnr, "readonly", true)
        
        -- Close with q
        vim.keymap.set("n", "q", function()
          win:unmount()
        end, { buffer = win.bufnr, noremap = true })
      end
      
      -- Show dashboard
      function analytics.show_dashboard()
        -- Create window
        local win = require("nui.popup")({
          enter = true,
          focusable = true,
          border = {
            style = "rounded",
            text = {
              top = " Test Analytics Dashboard ",
              top_align = "center",
            },
          },
          position = "50%",
          size = {
            width = "60%",
            height = "40%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })
        
        win:mount()
        
        -- Prepare data
        local metrics = analytics.metrics
        
        -- Create ASCII graph of pass rate trend
        local pass_rate_graph = {}
        local runs = analytics.history.runs
        local points = {}
        
        -- Get last 10 pass rates
        local max_points = 10
        for i = math.max(1, #runs - max_points + 1), #runs do
          local run = runs[i]
          if run.total > 0 then
            table.insert(points, (run.passed / run.total) * 100)
          end
        end
        
        -- Generate graph if we have data
        if #points > 0 then
          local max_val = 100  -- 100%
          local min_val = math.max(0, math.min(unpack(points)) - 10)  -- Lowest - 10%
          local height = 5  -- Graph height in lines
          
          -- Initialize graph lines
          for _ = 1, height do
            table.insert(pass_rate_graph, string.rep(" ", #points * 2))
          end
          
          -- Plot points
          for x, val in ipairs(points) do
            local normalized = (val - min_val) / (max_val - min_val)
            local y = math.floor((1 - normalized) * (height - 1)) + 1
            y = math.max(1, math.min(y, height))
            
            -- Update character at position
            local line = pass_rate_graph[y]
            local pos = (x - 1) * 2 + 1
            local char = "o"
            
            -- Connect points
            if x > 1 then
              local prev_val = points[x-1]
              local prev_normalized = (prev_val - min_val) / (max_val - min_val)
              local prev_y = math.floor((1 - prev_normalized) * (height - 1)) + 1
              prev_y = math.max(1, math.min(prev_y, height))
              
              -- Draw connecting line
              if prev_y < y then
                for i = prev_y, y - 1 do
                  local connecting_line = pass_rate_graph[i]
                  pass_rate_graph[i] = connecting_line:sub(1, pos - 1) .. "|" .. connecting_line:sub(pos + 1)
                end
              elseif prev_y > y then
                for i = y + 1, prev_y do
                  local connecting_line = pass_rate_graph[i]
                  pass_rate_graph[i] = connecting_line:sub(1, pos - 1) .. "|" .. connecting_line:sub(pos + 1)
                end
              end
            end
            
            pass_rate_graph[y] = line:sub(1, pos - 1) .. char .. line:sub(pos + 1)
          end
          
          -- Add axis labels
          table.insert(pass_rate_graph, string.rep("-", #points * 2))
          table.insert(pass_rate_graph, string.format("%.0f%%", min_val) .. string.rep(" ", #points * 2 - 8) .. string.format("%.0f%%", max_val))
        end
        
        -- Create lines
        local lines = {
          "Test Analytics Dashboard",
          string.rep("=", 50),
          "",
          "Overview:",
          string.format("Total Runs:        %d", metrics.total_runs),
          string.format("Overall Pass Rate: %.1f%%", metrics.pass_rate),
          string.format("Recent Pass Rate:  %.1f%%", metrics.recent_pass_rate),
          string.format("Flaky Tests:       %d", vim.tbl_count(metrics.flaky_tests)),
          string.format("Failure Patterns:  %d", vim.tbl_count(metrics.failure_patterns)),
          "",
          "Pass Rate Trend:",
        }
        
        -- Add graph
        for _, line in ipairs(pass_rate_graph) do
          table.insert(lines, line)
        end
        
        if #pass_rate_graph == 0 then
          table.insert(lines, "Not enough data to display trend")
        end
        
        table.insert(lines, "")
        table.insert(lines, "Health Status:")
        
        -- Calculate health status
        local health_status = "Good"
        local health_details = {}
        
        if metrics.recent_pass_rate < 90 then
          health_status = "Poor"
          table.insert(health_details, "Recent pass rate below 90%")
        end
        
        if vim.tbl_count(metrics.flaky_tests) > 3 then
          health_status = "Poor"
          table.insert(health_details, "Too many flaky tests")
        end
        
        if metrics.recent_pass_rate < metrics.pass_rate * 0.95 then
          health_status = "Declining"
          table.insert(health_details, "Pass rate is trending downward")
        end
        
        table.insert(lines, health_status)
        
        if #health_details > 0 then
          table.insert(lines, "Issues:")
          for _, detail in ipairs(health_details) do
            table.insert(lines, "- " .. detail)
          end
        end
        
        -- Set content
        vim.api.nvim_buf_set_lines(win.bufnr, 0, -1, false, lines)
        
        -- Add highlighting
        local ns_id = vim.api.nvim_create_namespace("TestAnalytics")
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 3, 0, -1)
        vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "Title", 10, 0, -1)
        
        -- Highlight health status
        local health_line = #lines - #health_details - 1
        if health_status == "Good" then
          vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "DiagnosticOk", health_line, 0, -1)
        elseif health_status == "Declining" then
          vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "DiagnosticWarn", health_line, 0, -1)
        else
          vim.api.nvim_buf_add_highlight(win.bufnr, ns_id, "DiagnosticError", health_line, 0, -1)
        end
        
        -- Make buffer readonly
        vim.api.nvim_buf_set_option(win.bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(win.bufnr, "readonly", true)
        
        -- Close with q
        vim.keymap.set("n", "q", function()
          win:unmount()
        end, { buffer = win.bufnr, noremap = true })
      end
      
      -- Hook into test reporter
      vim.api.nvim_create_autocmd("User", {
        pattern = "NeotestRunComplete",
        callback = function()
          -- Try to get result from test reporter
          local ok, test_reporter = pcall(require, "user.test-reporter")
          if ok and test_reporter and test_reporter.state and test_reporter.state.current_run then
            analytics.record_run(test_reporter.state.current_run)
          end
        end,
      })
      
      -- Try to load existing history
      analytics.load_history()
      
      -- Export module
      package.loaded["test-analytics"] = analytics
      return analytics
    end,
  },
}

