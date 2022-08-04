scriptencoding utf-8

setlocal signcolumn=yes

lua << EOF
for lnum = 1, vim.fn.line('$') do
  local line = vim.fn.getline(lnum)
  if line == '' then
    vim.fn.sign_unplace('web-devicons', { lnum=lnum })
  else
    local fname = vim.fn.fnamemodify(line, ':t')
    local extension = vim.fn.fnamemodify(line, ':e')
    if vim.fn.isdirectory(line) == 1 then
      vim.fn.sign_define('', { text='' })
      vim.fn.sign_place(lnum, 'web-devicons', '', vim.fn.bufnr(), { lnum=lnum })
    else
      local icon, color = require'nvim-web-devicons'.get_icon(fname, extension, {default=true})
      vim.fn.sign_define(icon, { text=icon, texthl=color })
      vim.fn.sign_place(lnum, 'web-devicons', icon, vim.fn.bufnr(), { lnum=lnum })
    end
  end
end
EOF

if has('nvim')
lua << EOF
vim.api.nvim_buf_set_keymap(0, "n", "%", ":lua require'dirvish'.create_file()<CR>", { silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "d", ":lua require'dirvish'.create_dir()<CR>", { silent = true, nowait = true })
vim.api.nvim_buf_set_keymap(0, "n", "D", ":lua require'dirvish'.delete()<CR>", { silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "R", ":lua require'dirvish'.rename()<CR>", { silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "X", ":lua require'dirvish'.clear_arglist()<CR>", { silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F5>", ":lua require'dirvish'.explore()<CR>", { silent = true })
EOF
endif
