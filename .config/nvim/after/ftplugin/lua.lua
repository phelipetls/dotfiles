vim.bo.makeprg = "luacheck --no-color"
vim.opt_local.errorformat:append({ "%-G%.%#" })

vim.bo.formatprg = "stylua --search-parent-directories -"

vim.bo.suffixesadd = ".lua"

-- force Neovim to always use includeexpr
vim.bo.path = ""

local lua_path = table.concat({ vim.go.path, "lua", "./lua" }, ",")
_G.find_lua_file = function(target)
  local file_path = target:gsub("%.", "/")

  local directory = vim.fn.finddir(file_path, lua_path)
  if directory ~= "" then
    local init_lua = vim.fn.findfile("init.lua", directory)

    if init_lua ~= "" then
      return init_lua
    end
  end

  return vim.fn.findfile(file_path, lua_path)
end

vim.bo.includeexpr = "v:lua.find_lua_file(v:fname)"
