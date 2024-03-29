vim.b.coc_root_patterns = {
  ".git",
  ".env",
  "venv",
  ".venv",
  "setup.cfg",
  "setup.py",
  "pyproject.toml",
  "pyrightconfig.json",
}

if vim.fn.executable("black") == 1 then
  vim.bo.formatprg = "black --quiet -"
end

if vim.fn.executable("python3") == 1 then
  local fname = vim.fn.expand("%:p:t")

  if vim.startswith(fname, "test") or vim.endswith(fname, "test") then
    if vim.fn.executable("pytest") == 1 then
      vim.cmd.compiler("pytest")
    else
      vim.cmd.compiler("pyunit")
    end
  else
    vim.cmd.compiler("flake8")
  end
end

if vim.fn.executable("python3") == 1 then
  vim.keymap.set("n", "<F5>", "<cmd>w !python3<CR>", { buffer = true })
end

vim.opt_local.path:append({ "./tests", "./templates", "./tests/conftest.py" })

vim.b[string.format("surround_%s", vim.fn.char2nr("p"))] = "print(\r)"
