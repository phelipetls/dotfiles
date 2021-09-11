local M = {}

local function remove_comments(line)
  return line:gsub("/%*.*%*/", ""):gsub("//.*", "")
end

local function decode_json_with_comments(json_file)
  local json_without_comments = vim.tbl_map(remove_comments, vim.fn.readfile(json_file))
  return vim.fn.json_decode(json_without_comments)
end

local function find_file(fname, path)
  local found = vim.fn.findfile(fname, path or "")
  if found ~= "" then
    return found
  end
end

local function find_dir(fname, path)
  local found = vim.fn.finddir(fname, path or "")
  if found ~= "" then
    return found
  end
end

local function get_tsconfig_file()
  return find_file("tsconfig.json", ".;") or find_file("jsconfig.json", ".;")
end

local function get_dir(fname)
  return vim.fn.fnamemodify(fname, ":h")
end

local function find_tsconfig_extends(extends, tsconfig_fname)
  if not extends or vim.startswith(extends, "@") then
    return
  end

  local tsconfig_dir = get_dir(tsconfig_fname)

  if vim.startswith(extends, "../") then
    return find_file(extends, tsconfig_dir)
  end

  return tsconfig_dir .. "/" .. extends
end

local function remove_wildcard(path)
  local str, _ = path:gsub("*", "")
  return str
end

-- Get all possible configured `.compilerOptions.paths` values by walking
-- through all tsconfig.json files recursively. If it finds a base
-- configuration (`.extends` key), it will continue to search there.
-- See https://www.typescriptlang.org/docs/handbook/module-resolution.html#path-mapping.
local function get_tsconfig_paths(tsconfig_fname, prev_base_url)
  if not tsconfig_fname then
    return {}
  end

  local alias_to_path = {}

  local json = decode_json_with_comments(tsconfig_fname)
  local base_url = json and json.compilerOptions and json.compilerOptions.baseUrl or prev_base_url

  if json and json.compilerOptions and json.compilerOptions.paths then

    for alias, paths in pairs(json.compilerOptions.paths) do
      for _, path in pairs(paths) do
        alias_to_path[alias] = vim.fn.simplify(
          get_dir(tsconfig_fname) .. "/" .. base_url .. "/" .. remove_wildcard(path)
        )
      end
    end
  end

  -- If tsconfig has a `.extends` field, we must search there too.
  local tsconfig_extends = find_tsconfig_extends(json.extends, tsconfig_fname)

  if tsconfig_extends then
    return vim.tbl_extend("force", alias_to_path, get_tsconfig_paths(tsconfig_extends, base_url))
  end

  return alias_to_path
end

-- Get `.include` array from a tsconfig.json file as comma separated string.
local function get_tsconfig_include(tsconfig)
  if not tsconfig then
    return
  end
  local json = decode_json_with_comments(tsconfig)
  if json.include then
    return table.concat(json.include, ",")
  end
  return ""
end

function M.get_tsconfig_include()
  return get_tsconfig_include(get_tsconfig_file())
end

local function expand_tsconfig_path(input)
  local tsconfig_file = get_tsconfig_file()

  if not tsconfig_file then
    return input
  end

  local alias_to_path = get_tsconfig_paths(tsconfig_file)

  if vim.tbl_isempty(alias_to_path) then
    return input
  end

  for alias, path in pairs(alias_to_path) do
    local alias_without_wildcard = alias:gsub("*", "")

    if vim.startswith(input, alias_without_wildcard) then
      local expanded_path = input:gsub(alias, path)
      local real_path = find_file(expanded_path) or find_dir(expanded_path)

      if real_path then return real_path end
    end
  end

  return input
end

function M.includeexpr(input)
  local path = expand_tsconfig_path(input)

  path = find_file(path) or find_dir(path)

  if vim.fn.isdirectory(path) == 1 then
    path = find_file("index", path) or path
  end

  return path
end

return M
