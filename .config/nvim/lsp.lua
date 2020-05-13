-- vim.lsp.stop_client(vim.lsp.buf_get_clients())

local nvim_lsp = require'nvim_lsp'
local util = require'nvim_lsp/util'
local configs = require'nvim_lsp/configs'

local severity_map = { "E", "W", "I", "H" }

local parse_diagnostics = function(diagnostics)
  if not diagnostics then return end
  local items = {}
  for _, diagnostic in ipairs(diagnostics) do
    local fname = vim.fn.bufname()
    local position = diagnostic.range.start
    local severity = diagnostic.severity
    table.insert(items, {
      filename = fname,
      type = severity_map[severity],
      lnum = position.line + 1,
      col = position.character + 1,
      text = diagnostic.message:gsub("\r", ""):gsub("\n", " ")
    })
  end
  return items
end

vim.lsp.util.buf_diagnostics_signs = function() return end
vim.lsp.util.buf_diagnostics_virtual_text = function() return end

local close_loclist_if_empty = function()
  local loclist = vim.fn.getloclist(0, { title = 0, size = 0})

  local title = loclist.title
  local size = loclist.size

  if title == 'Language Server' and size == 0 then
    vim.api.nvim_command [[lclose]]
  end
end

update_diagnostics_loclist = function()
  bufnr = vim.fn.bufnr()
  diagnostics = vim.lsp.util.diagnostics_by_buf[bufnr]

  items = parse_diagnostics(diagnostics)
  vim.lsp.util.set_loclist(items)

  close_loclist_if_empty()
end

local function set_lsp_config(_)
  vim.api.nvim_command [[setlocal omnifunc=v:lua.vim.lsp.omnifunc]]
  vim.api.nvim_command [[command! -buffer RenameLSP lua vim.lsp.buf.rename()]]
  vim.api.nvim_command [[nnoremap <buffer><silent> K :lua vim.lsp.buf.hover()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gd :lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> [<C-d> :lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> <C-w><C-d> :vs <bar> lua vim.lsp.buf.definition()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> g0 :lua vim.lsp.buf.document_symbol()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gs :lua vim.lsp.buf.signature_help()<CR>]]
  vim.api.nvim_command [[nnoremap <buffer><silent> gr :lua vim.lsp.buf.references()<CR>]]
  vim.api.nvim_command [[let b:vsc_completion_command = "\<C-x>\<C-o>"]]
  vim.api.nvim_command [[autocmd! User LspDiagnosticsChanged lua update_diagnostics_loclist()]]
  vim.api.nvim_command [[autocmd! CursorHold <buffer> lua vim.lsp.util.show_line_diagnostics()]]
end

nvim_lsp.pyls.setup{
  on_attach=set_lsp_config;
  settings = {
    pyls = {
      plugins = {
        pycodestyle = { enabled = false; };
        pyflakes = { enabled = false; };
        yapf = { enabled = false; };
      };
    };
  };
};

nvim_lsp.tsserver.setup{
  on_attach = set_lsp_config;
  root_dir = function(fname)
    return util.find_package_json_ancestor(fname) or
           util.find_git_ancestor(fname) or
           vim.loop.os_homedir()
  end;
}

if not configs.r_language_server then
  configs.r_language_server = {
    default_config = {
      cmd = {"R", "--slave", "-e", "languageserver::run()"};
      filetypes = {"r", "rmd"};
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      log_level = vim.lsp.protocol.MessageType.Warning;
      settings = {};
    }
  }
end

nvim_lsp.r_language_server.setup{
  on_attach=set_lsp_config;
}
