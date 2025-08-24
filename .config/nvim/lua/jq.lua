-- jq.lua - Interactive jq filter plugin for Neovim
local M = {}

-- Plugin configuration
local config = {
  filter_window_height = 8, -- Height of the filter window
  auto_apply = true, -- Whether to apply filters in real-time
}

-- Plugin state
local jq_state = {
  original_buffer = nil,
  original_content = {},
  filter_buffer = nil,
  filter_window = nil,
  is_active = false,
  original_window = nil
}

-- Utility function to run jq command
local function run_jq(json_content, filter)
  if not filter or filter == "" or filter == "." then
    return json_content
  end

  -- Create temporary file for input
  local temp_input = vim.fn.tempname()
  local temp_output = vim.fn.tempname()

  -- Write JSON content to temp file
  local input_file = io.open(temp_input, "w")
  if not input_file then
    return json_content
  end

  for _, line in ipairs(json_content) do
    input_file:write(line .. "\n")
  end
  input_file:close()

  -- Run jq command
  local cmd = string.format("jq '%s' '%s' > '%s' 2>/dev/null", filter, temp_input, temp_output)
  local success = os.execute(cmd)

  -- Clean up input file
  os.remove(temp_input)

  if success == 0 then
    -- Read output
    local output_file = io.open(temp_output, "r")
    if output_file then
      local result = {}
      for line in output_file:lines() do
        table.insert(result, line)
      end
      output_file:close()
      os.remove(temp_output)

      -- If result is empty, return original content
      if #result == 0 then
        return json_content
      end

      return result
    end
  end

  -- Clean up output file on failure
  os.remove(temp_output)

  -- Return original content if jq failed
  return json_content
end

-- Function to apply jq filter
local function apply_jq_filter()
  if not jq_state.is_active then
    return
  end

  -- Get filter text from filter buffer
  local filter_lines = vim.api.nvim_buf_get_lines(jq_state.filter_buffer, 0, -1, false)
  local filter = table.concat(filter_lines, " "):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace

  -- Apply jq filter
  local result = run_jq(jq_state.original_content, filter)

  -- Update original buffer with result
  vim.api.nvim_buf_set_lines(jq_state.original_buffer, 0, -1, false, result)
end

-- Function to close jq session
local function close_jq_session()
  if not jq_state.is_active then
    return
  end

  -- Close filter window if it exists
  if jq_state.filter_window and vim.api.nvim_win_is_valid(jq_state.filter_window) then
    vim.api.nvim_win_close(jq_state.filter_window, true)
  end

  -- Delete filter buffer if it exists
  if jq_state.filter_buffer and vim.api.nvim_buf_is_valid(jq_state.filter_buffer) then
    vim.api.nvim_buf_delete(jq_state.filter_buffer, { force = true })
  end

  -- Focus back to original window
  if jq_state.original_window and vim.api.nvim_win_is_valid(jq_state.original_window) then
    vim.api.nvim_set_current_win(jq_state.original_window)
  end

  -- Reset state
  jq_state = {
    original_buffer = nil,
    original_content = {},
    filter_buffer = nil,
    filter_window = nil,
    is_active = false,
    original_window = nil
  }
end

-- Function to setup filter buffer keymaps and autocmds
local function setup_filter_buffer(initial_filter)
  -- Set buffer options
  vim.api.nvim_buf_set_option(jq_state.filter_buffer, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(jq_state.filter_buffer, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(jq_state.filter_buffer, 'swapfile', false)

  -- Set initial content
  local filter_content = initial_filter or "."
  vim.api.nvim_buf_set_lines(jq_state.filter_buffer, 0, -1, false, { filter_content })

  -- Set buffer name
  vim.api.nvim_buf_set_name(jq_state.filter_buffer, "[jq filter]")

  -- Setup keymaps for the filter buffer
  local opts = { buffer = jq_state.filter_buffer, silent = true }

  -- Enter to apply filter
  vim.keymap.set('n', '<CR>', apply_jq_filter, opts)
  vim.keymap.set('i', '<CR>', function()
    apply_jq_filter()
  end, opts)

  -- Escape in insert mode goes to normal mode (standard behavior)
  vim.keymap.set('i', '<Esc>', '<Esc>', { buffer = jq_state.filter_buffer, silent = true, remap = false })

  -- Ctrl-C to close session
  vim.keymap.set({ 'n', 'i' }, '<C-c>', close_jq_session, opts)

  -- Setup autocmds for real-time filtering (if enabled)
  if config.auto_apply then
    -- Only apply filter on TextChanged (normal mode), not TextChangedI (insert mode)
    vim.api.nvim_create_autocmd('TextChanged', {
      buffer = jq_state.filter_buffer,
      callback = function()
        -- Small delay to avoid excessive calls
        vim.defer_fn(apply_jq_filter, 100)
      end
    })

    -- Apply filter when leaving insert mode
    vim.api.nvim_create_autocmd('InsertLeave', {
      buffer = jq_state.filter_buffer,
      callback = function()
        apply_jq_filter()
      end
    })
  end

  -- Auto-close when buffer is deleted or window is closed
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    buffer = jq_state.filter_buffer,
    callback = close_jq_session,
    once = true
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    callback = function(args)
      local win_id = tonumber(args.match)
      if win_id == jq_state.filter_window then
        close_jq_session()
      end
    end
  })
end

-- Main function to start jq session
function M.start_jq(args)
  -- Check if jq is available
  if vim.fn.executable('jq') ~= 1 then
    vim.notify("jq is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end

  -- Parse arguments
  local initial_filter = nil
  if args and args.args and args.args ~= "" then
    initial_filter = args.args
  end

  -- Close existing session if active
  if jq_state.is_active then
    close_jq_session()
  end

  -- Get current buffer and its content
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local content = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

  -- Check if buffer has content
  if #content == 0 or (#content == 1 and content[1] == "") then
    vim.notify("Buffer is empty", vim.log.levels.WARN)
    return
  end

  -- Store original state
  jq_state.original_buffer = current_buf
  jq_state.original_content = vim.deepcopy(content)
  jq_state.original_window = current_win
  jq_state.is_active = true

  -- Get current window dimensions
  local win_width = vim.api.nvim_win_get_width(current_win)
  local win_height = vim.api.nvim_win_get_height(current_win)

  -- Calculate filter window height
  local filter_height = math.min(config.filter_window_height, math.max(1, math.floor(win_height * 0.4)))

  -- Create filter buffer
  jq_state.filter_buffer = vim.api.nvim_create_buf(false, true)

  -- Create horizontal split below current window
  vim.cmd('botright split')
  jq_state.filter_window = vim.api.nvim_get_current_win()

  -- Set the filter buffer in the new window
  vim.api.nvim_win_set_buf(jq_state.filter_window, jq_state.filter_buffer)

  -- Resize the filter window
  vim.api.nvim_win_set_height(jq_state.filter_window, filter_height)

  -- Setup filter buffer
  setup_filter_buffer(initial_filter)

  -- Apply initial filter if provided
  if initial_filter then
    apply_jq_filter()
  end

  -- Start in insert mode at the end of the line
  vim.cmd('startinsert!')
  local filter_line_length = #(initial_filter or ".")
  vim.api.nvim_win_set_cursor(jq_state.filter_window, { 1, filter_line_length })

  -- Show help message
  vim.notify("jq filter active - <CR>: apply, <C-c>: close", vim.log.levels.INFO)
end

-- Setup function
function M.setup(opts)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend('force', config, opts or {})

  -- Create user command
  vim.api.nvim_create_user_command('Jq', M.start_jq, {
    desc = 'Start interactive jq filtering session',
    nargs = '?',  -- Optional argument
    complete = function(arglead, cmdline, cursorpos)
      -- Basic jq filter completions
      local completions = {
        '.',
        '.[]',
        '.foo',
        '.[].',
        'keys',
        'length',
        'type',
        'select(.)',
        'map(.)',
        'sort_by(.)',
        'group_by(.)',
        'unique',
        'reverse',
      }

      local matches = {}
      for _, comp in ipairs(completions) do
        if comp:sub(1, #arglead) == arglead then
          table.insert(matches, comp)
        end
      end
      return matches
    end
  })

  -- Optional: Create a keymap
  -- vim.keymap.set('n', '<leader>jq', M.start_jq, { desc = 'Start jq filter' })
end

return M
