local M = {}

local function show_error(error_message)
  vim.cmd.echohl("'ErrorMsg'")
  vim.cmd.echo(string.format("'%s'", error_message))
  vim.cmd.echohl("'None'")
end

local function is_different(path)
  local diff_result = vim.fn.FugitiveExecute("diff", "HEAD", "--exit-code", "--", path)
  return diff_result.exit_status > 0
end

local function get_hexadecimal(str)
  return str:match("%x+")
end

M.blame_current_line = function()
  if vim.fn.FugitiveGitDir == "" then
    show_error("Failed to run git blame: not in a git directory")
    return
  end

  local full_path = vim.fn.expand("%:p")
  local revision = "HEAD"

  local git_blame_args = {
    "blame",
    "--porcelain",
    "-L",
    string.format("%s,+1", vim.fn.line(".")),
  }

  if vim.bo.modified or is_different(full_path) then
    vim.list_extend(git_blame_args, {
      "--contents",
      full_path,
    })
  else
    if vim.startswith(full_path, "fugitive://") then
      local file_with_revision = vim.fn.FugitiveParse()[1]

      if file_with_revision == "" then
        show_error("Unexpected empty FugitiveParse output.")
        return
      end

      revision = get_hexadecimal(file_with_revision)
    end

    vim.list_extend(git_blame_args, {
      revision,
    })
  end

  vim.list_extend(git_blame_args, {
    "--",
    full_path,
  })

  local blame_result = vim.fn.FugitiveExecute(unpack(git_blame_args))

  if blame_result.exit_status > 0 then
    local error_message = table.concat(blame_result.stderr, "")
    show_error("Failed to run git blame: " .. error_message)

    return
  end

  local stdout = blame_result.stdout

  local first_line = stdout[1]
  if first_line == "" then
    show_error("Failed to run git blame: couldn't find a commit to blame")
    return
  end

  local commit = first_line:match("%x+")
  if commit == "" then
    show_error("Failed to run git blame: couldn't find a commit to blame")
    return
  end

  if commit:match("^0+$") then
    vim.cmd.echomsg("'Not Committed Yet'")
    return
  end

  vim.cmd(vim.fn["fugitive#Open"]("botright pedit", 0, "", commit, {}))
end

return M
