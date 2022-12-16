-- {{{ plugins

require("impatient")

-- prevent loading netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("packadd! cfilter")

-- optimization
vim.cmd("packadd! LargeFile")
vim.cmd("packadd! impatient.nvim")

-- misc
vim.cmd("packadd! plenary.nvim")

-- colorscheme
vim.cmd("packadd! vim-moonfly-colors")
vim.g.moonflyWinSeparator = 2
vim.cmd.colorscheme("moonfly")

-- text editing
vim.cmd("packadd! vim-surround")
vim.cmd("packadd! vim-commentary")
vim.cmd("packadd! vim-repeat")
vim.cmd("packadd! vim-unimpaired")
vim.cmd("packadd! vim-speeddating")

vim.cmd("packadd! vim-abolish")

vim.cmd("packadd! vim-lion")
vim.cmd("packadd! vim-sleuth")
vim.cmd("packadd! vim-matchup")

vim.cmd("packadd! inline_edit.vim")
vim.keymap.set("n", "<C-c>", "<cmd>InlineEdit<CR>")
vim.g.inline_edit_autowrite = 1

vim.cmd("packadd! treesj")
vim.keymap.set("n", "gJ", "<cmd>TSJJoin<CR>")
vim.keymap.set("n", "gS", "<cmd>TSJSplit<CR>")
require("treesj").setup({
  use_default_keymaps = false,
})

vim.cmd("packadd! editorconfig-vim")
vim.g.EditorConfig_exclude_patterns = { "fugitive://.*", "scp://.*" }

-- git
vim.cmd("packadd! vim-fugitive")
vim.cmd("packadd! vim-rhubarb")
vim.cmd("packadd! fugitive-gitlab.vim")
vim.cmd("packadd! vim-fugitive-blame-ext")

-- file navigation
vim.cmd("packadd! vim-dirvish")
vim.g.dirvish_mode = [[:sort ,^.*[\/],]]

vim.cmd("packadd! fzf-lua")
require("plugins.config.fzf_lua")

-- lsp
vim.cmd("packadd! coc.nvim")
require("plugins.config.coc")

-- incremental search/substitute highlighting
vim.cmd("packadd traces.vim")
vim.g.traces_abolish_integration = 1

-- session management
vim.cmd("packadd! vim-obsession")
vim.g.obsession_no_bufenter = 1

-- repl
vim.cmd("packadd! vim-slime")
require("plugins.config.slime")

-- json
vim.cmd("packadd! vim-jqplay")
vim.g.jqplay = {
  mods = "vertical",
}

vim.cmd("packadd! jsonpath.nvim")

-- web development with hugo
vim.cmd("packadd! vim-hugo")

-- appearance
vim.cmd("packadd! lualine.nvim")
require("plugins.config.lualine")

vim.cmd("packadd! nvim-pqf")
require("pqf").setup()

vim.cmd("packadd! headlines.nvim")
require("headlines").setup({
  mdx = vim.tbl_deep_extend("force", require("headlines").config.markdown, {
    treesitter_language = "markdown",
  }),
})

-- treesitter
vim.cmd("packadd! nvim-treesitter")
require("plugins.config.treesitter")

vim.cmd("packadd! nvim-ts-context-commentstring")
vim.cmd("packadd! nvim-ts-autotag")
vim.cmd("packadd! nvim-treesitter-textobjects")
vim.cmd("packadd! playground")

-- debugging
vim.cmd("packadd! debugprint.nvim")
require("debugprint").setup({
  create_keymaps = false,
})

-- }}}
-- {{{ settings

vim.cmd("filetype plugin indent on")

vim.o.termguicolors = true
vim.o.number = false
vim.o.ruler = false
vim.o.wildmode = "full"
vim.o.lazyredraw = true
vim.o.mouse = "nv"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showcmd = false
vim.o.cursorline = false
vim.o.scrolloff = 3
vim.o.backspace = "indent,eol,start"
vim.o.laststatus = 2
vim.o.showmode = false
vim.o.updatetime = 1000
vim.o.breakindent = true
vim.o.breakindentopt = "shift:2"
vim.o.linebreak = true
vim.o.showtabline = 2

-- clipboard
vim.opt.clipboard:append({ "unnamedplus" })

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "Windows",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = [[powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
      ["*"] = [[powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
    },
  }
end

-- tabline
vim.o.tabline = "%{%v:lua.require('helpers.tabline').get()%}"

-- file navigation
vim.opt.path = { ".", "", ".." }

-- ignore these files while browsing
vim.opt.wildignore = {
  "venv*/",
  "__pycache__/",
  ".pytest_cache/",
  "tags",
  "htmlcov/.coverage",
  "*.pyc",
  "package-lock.json",
}

-- tell neovim where python3 is -- this improves startup time
if vim.fn.executable("/usr/bin/python3") == 1 then
  vim.g.loaded_python_provider = 0
  vim.g.python3_host_prog = "/usr/bin/python3"
end

vim.opt.diffopt:append({
  foldcolumn = 0,
  hiddenoff = true,
  ["indent-heuristic"] = true,
  internal = true,
  algorithm = "patience",
})

-- visually show special characters
vim.o.list = true

vim.opt.fillchars = {
  fold = "-",
  vert = "┃",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vertleft = "┨",
  vertright = "┣",
  verthoriz = "╋",
}

vim.opt.listchars = {
  tab = "» ",
  nbsp = "¬",
  trail = "·",
  extends = "…",
  precedes = "‹",
}

vim.o.showbreak = "↳ "

-- use ripgrep as the external grep command
if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --smart-case --hidden"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- alias for vim.pretty_print
_G.pp = vim.pretty_print

-- persist workspace folders
-- see https://github.com/neoclide/coc.nvim/wiki/Using-workspaceFolders#persist-workspace-folders
vim.opt.sessionoptions:append({ "globals" })

-- disable colors in deno and nodejs terminal output
vim.env.NO_COLOR = 0

-- avoid showing ansi escape sequences in nvim terminal
-- such as in lint-staged output before committing
vim.g.fugitive_pty = 0

-- remove -F flag I use in my .profile, that would automatically close terminal
-- window if output in less is too short
vim.env.LESS = "RX"

-- }}}
-- {{{ keymaps

-- general keymaps
vim.keymap.set("n", "gr", "gT", { desc = "Go to previous tab" })

vim.keymap.set("n", "<Esc>", function()
  vim.o.hlsearch = false
end, { silent = true, desc = "Disable highlight search" })

vim.keymap.set("n", "<space>ev", "<cmd>edit $MYVIMRC<CR>", {
  silent = true,
  desc = "Edit Neovim configuration file",
})

vim.keymap.set("n", "<space>ss", function()
  if vim.bo.filetype == "vim" or vim.fn.expand("%:t") == "init.lua" then
    vim.cmd.source("%")
    return
  end

  if vim.bo.filetype == "lua" then
    local module = vim.fn.expand("%:t:r")
    require("plenary.reload").reload_module(module)
  end
end, { desc = "Reload current Lua/VimScript file" })

vim.keymap.set({ "x", "n" }, "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true, desc = "Skip wrapped lines when using a count to jump lines up" })

vim.keymap.set({ "x", "n" }, "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true, desc = "Skip wrapped lines when using a count to jump lines down" })

vim.keymap.set("n", "'", "`", { desc = "Jump to exact location of a mark" })

vim.keymap.set("n", "<C-w><C-q>", "<cmd>close<CR>", { silent = true, desc = "Close split" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { silent = true, desc = "Move to split below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { silent = true, desc = "Move to split above" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { silent = true, desc = "Move split at the right" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { silent = true, desc = "Move split at the left" })

vim.keymap.set("n", "<C-Left>", "<C-w>>", { silent = true, desc = "Increase split width" })
vim.keymap.set("n", "<C-Right>", "C-w><", { silent = true, desc = "Decrease split width" })
vim.keymap.set("n", "<C-Up>", "<C-w>+", { silent = true, desc = "Increase split height" })
vim.keymap.set("n", "<C-Down>", "<C-w>-", { silent = true, desc = "Decrease split height" })

vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Keep selected lines when indenting" })
vim.keymap.set("v", "<", "<gv", { silent = true, desc = "Keep selected lines when deindenting" })

vim.keymap.set("n", "gy", "`[v`]", { silent = true, desc = "Select last modified/yanked text" })

vim.keymap.set("n", "Q", "", { desc = "Disable switching to Ex mode with Q" })

vim.keymap.set("n", "<C-n>", "*Ncgn", { silent = true, desc = "Substitute word under cursor" })

vim.keymap.set("n", "<M-q>", "gwip", { desc = "Format paragraph" })

vim.keymap.set({ "i", "c" }, "<C-a>", "<Home>", { desc = "Go to start of line" })
vim.keymap.set("c", "<C-x><C-a>", "<C-a>", { desc = "Insert previously inserted text" })

vim.keymap.set("i", "<C-k>", "<C-o>D", { desc = "Delete until end of line" })
vim.keymap.set("i", "<C-x><C-k>", "<C-k>", { desc = "Insert digraph" })

vim.keymap.set("i", "<C-e>", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  if col == #line then
    return "<C-e>"
  end

  return "<End>"
end, {
  expr = true,
  desc = "Go to end of line, if not already otherwise fallback to built-in behaviour of re-using character in the line above",
})

-- autocomplete dates
_G.get_formatted_dates = function()
  local date_formats = { "%Y-%m-%d", "%Y-%m-%dT%H:%M:%S%Z" }

  local dates = vim.tbl_map(function(date_format)
    return vim.fn.strftime(date_format)
  end, date_formats)

  return dates
end

vim.keymap.set("i", "<C-g><C-t>", "<C-r>=repeat(complete(col('.'),v:lua.get_formatted_dates()),0)<CR>", {
  silent = true,
  nowait = true,
  desc = "Insert today's date in most common date formats",
})

-- <space> should not move cursor in normal mode
vim.keymap.set("n", "<space>", "")

vim.keymap.set(
  "c",
  "<C-r><C-l>",
  [[<C-R>=substitute(getline('.'), '^\s*', '', '')<CR>]],
  { desc = "Use current line in command-line mode, but strip trailing space" }
)

vim.keymap.set({ "o", "x" }, "<Tab>", "%", { desc = "Use matchit to go to matching brackets etc." })

vim.keymap.set("n", "y<C-p>", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy current file name" })

vim.keymap.set("n", "gb", function()
  require("helpers.gitblame").blame_current_line()
end, { silent = true, desc = "Blame current line with fugitive" })

-- gx
vim.g.netrw_nogx = 1
vim.keymap.set({ "n", "v" }, "gx", function()
  require("helpers.os").open_under_cursor()
end, { silent = true, desc = "Open file/URL under cursor" })

-- formatting
vim.keymap.set(
  "n",
  "gq",
  "<cmd>set operatorfunc=format#operatorfunc<CR>g@",
  { silent = true, desc = "Normal-mode operator to format lines" }
)
vim.keymap.set(
  "v",
  "gq",
  "<C-U><cmd>set operatorfunc=format#operatorfunc<CR>gvg@",
  { silent = true, desc = "Visual-mode operator to format lines" }
)

vim.keymap.set("n", "gQ", "<cmd>call format#file(0)<CR>", { silent = true })
vim.keymap.set("n", "<space>gQ", "<cmd>call format#file(1)<CR>", { silent = true })

-- git
for _, lhs in ipairs({ "<space>gg", "<space>g<space>" }) do
  vim.api.nvim_set_keymap("n", lhs, ":Git<space>", { noremap = true })
end

-- unimpaired-like mappings to ignore whitespace in diff
vim.keymap.set("n", "[oi", function()
  vim.opt.diffopt:append({ "iwhite" })
end, { silent = true, desc = "Ignore whitespace in diff" })

vim.keymap.set("n", "]oi", function()
  vim.opt.diffopt:remove({ "iwhite" })
end, { silent = true, desc = "Don't ignore whitespace in diff" })

vim.keymap.set("n", "yoi", function()
  if vim.o.diffopt:match("iwhite") then
    vim.opt.diffopt:remove({ "iwhite" })
  else
    vim.opt.diffopt:append({ "iwhite" })
  end
end, { silent = true, desc = "Toggle ignoring whitespace in diff" })

-- quickfix and location list
local qflist = require("helpers.qflist")
local loclist = require("helpers.qflist")

vim.keymap.set("n", "]q", function()
  qflist.next()
end, { silent = true, desc = "Wrap around when navigating the quickfix list forward" })

vim.keymap.set("n", "[q", function()
  qflist.prev()
end, { silent = true, desc = "Wrap around when navigating the quickfix list backwards" })

vim.keymap.set("n", "]l", function()
  loclist.next()
end, { silent = true, desc = "Wrap around when navigating the location list forward" })

vim.keymap.set("n", "[l", function()
  loclist.prev()
end, { silent = true, desc = "Wrap around when navigating the location list backwards" })

vim.keymap.set("n", "<space>q", function()
  qflist.toggle()
end, { silent = true, desc = "Toggle location list" })

vim.keymap.set("n", "<space>l", function()
  loclist.toggle()
end, { silent = true, desc = "Toggle location list" })

-- close tag
vim.keymap.set(
  "i",
  "<C-x>/",
  "</<C-r>=v:lua.require('helpers.close_tag').close_tag()<CR><C-r>=v:lua.require('helpers.close_tag').reindent()<CR><C-r>=v:lua.require('helpers.close_tag').cleanup()<CR>",
  { silent = true }
)

-- textobjects
_G.select_number = function()
  vim.fn.search([[\d\>]], "cW")
  vim.cmd.normal({ args = "v", bang = true })
  vim.fn.search([[\<\d]], "becW")
end

vim.keymap.set("x", "in", ":<C-u>lua=select_number()<CR>", { silent = true, desc = "Select nearest number" })
vim.keymap.set("o", "in", "<cmd>normal vin<CR>", { desc = "Operator pending for the nearest number" })

vim.keymap.set("x", "ir", "i[", { silent = true, desc = "Select everything inside brackets" })
vim.keymap.set("o", "ir", "<cmd>normal vi[<CR>", { desc = "Operator pending mode for everything inside brackets" })

vim.keymap.set("x", "ar", "a[", { silent = true, desc = "Select everything around brackets" })
vim.keymap.set("o", "ar", "<cmd>normal va[<CR>", { silent = true, desc = "Operator for everything around brackets" })

for _, char in ipairs({ "_", "-", "/", "*", "," }) do
  vim.keymap.set(
    "x",
    "i" .. char,
    (":<C-u>normal! T%svt%s<CR>"):format(char, char),
    { desc = string.format("Select everything inside character %s", char), silent = true }
  )

  vim.keymap.set(
    "o",
    "i" .. char,
    (":<C-u>normal vi%s<CR>"):format(char),
    { desc = string.format("Operator for everything inside character %s", char), silent = true }
  )

  vim.keymap.set(
    "x",
    "a" .. char,
    (":<C-u>normal! F%svf%s<CR>"):format(char, char),
    { desc = string.format("Select everything around character %s", char), silent = true }
  )

  vim.keymap.set(
    "o",
    "a" .. char,
    (":<C-u>normal va%s<CR>"):format(char),
    { desc = string.format("Operator for everything around character %s", char), silent = true }
  )
end

-- }}}
-- {{{ commands

vim.api.nvim_create_user_command("E", "e<bang>", { bang = true, complete = "file_in_path", nargs = "*" })
vim.api.nvim_create_user_command("W", "w<bang>", { bang = true })
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true })
vim.api.nvim_create_user_command("Qall", "qall<bang>", { bang = true })

vim.api.nvim_create_user_command("Hi", function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))

  local syn_id = vim.fn.synID(line, col, 0)
  local highlight_name = vim.fn.synIDattr(syn_id, "name")

  vim.cmd.hi(highlight_name ~= "" and highlight_name or nil)
end, { desc = "Show information about highlight group under cursor" })

vim.api.nvim_create_user_command("Browse", function(opts)
  local file = opts.args
  require("helpers.os").open(file)
end, { nargs = 1, desc = "Open file/URL with the operating system" })

vim.api.nvim_create_user_command("FormatPrg", "call format#file(<bang>0)", { bang = true })

-- }}}
-- {{{ autocmds

local global_autocmds_augroup = vim.api.nvim_create_augroup("GlobalAutocmds", {})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Don't autocomment on newline",
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") and not vim.bo.filetype:match("git") then
      vim.cmd.normal('g`"')
    end
  end,
  desc = "Recover last cursor position when opening a file, except on git commits etc.",
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  command = "wincmd =",
  desc = "Automatically resize splits when Neovim is resized",
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = global_autocmds_augroup,
  pattern = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "sh",
    "yaml",
    "vim",
    "lua",
    "json",
    "html",
    "css",
  },
  callback = function()
    vim.o.expandtab = true
    vim.o.shiftwidth = 2
    vim.o.softtabstop = 2
  end,
  desc = "Set up 2-space indentation for some file types",
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = global_autocmds_augroup,
  pattern = {
    "python",
  },
  callback = function()
    vim.o.expandtab = true
    vim.o.shiftwidth = 4
    vim.o.softtabstop = 4
  end,
  desc = "Set up 4-space indentation for some file types",
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local basename = vim.fs.basename(bufname)
    vim.fn.setreg("f", basename)
  end,
  desc = "Put the current file name under the f register",
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    local path = vim.fn.expand("<afile>:p")

    if path:match("^fugitive://") then
      return
    end

    vim.fn.mkdir(vim.fs.dirname(path), "p")
  end,
  desc = "create intermediate directories automatically before saving file",
})

vim.api.nvim_create_autocmd({ "VimResume", "FocusGained" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
  desc = "Automatically update file when Neovim resumes",
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = global_autocmds_augroup,
  pattern = { "*" },
  callback = function()
    vim.highlight.on_yank({ higroup = "Search", on_visual = false })
  end,
  desc = "Highlight yanked region",
})

local open_file_with_f5_autocmd = vim.api.nvim_create_augroup("OpenFileWithF5", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = open_file_with_f5_autocmd,
  pattern = { "html", "dirvish", "svg" },
  callback = function()
    vim.keymap.set("n", "<F5>", function()
      require("helpers.os").open(vim.fn.expand("%:p"))
    end, { desc = "Open current file with the operating system" })
  end,
})

local quickfix_augroup = vim.api.nvim_create_augroup("Quickfix", { clear = true })

vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
  group = quickfix_augroup,
  pattern = { "*" },
  callback = function()
    require("helpers.qflist").open()
  end,
  desc = "Open Quickfix list automatically",
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
  group = quickfix_augroup,
  pattern = { "*" },
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.o.buftype == "quickfix" then
      vim.cmd.quit()
    end
  end,
  desc = "Close quickfix list if it's the last window",
})

-- }}}
-- vim: foldmethod=marker
