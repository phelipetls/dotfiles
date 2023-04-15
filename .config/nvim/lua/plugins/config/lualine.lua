local function fugitivestatusline()
  local raw = vim.fn["FugitiveStatusline"]()

  -- extract from [Git:(branch)] pattern
  local branch = raw:match("%([^)]+%)"):sub(2, -2)

  -- truncate branch name
  local MAX_LENGTH = 25
  local truncated_branch = branch:sub(1, MAX_LENGTH)
  if branch ~= truncated_branch then
    truncated_branch = truncated_branch .. "…"
  end

  return string.format("[Git:(%s)]", truncated_branch)
end

local function filename()
  local bufname = vim.api.nvim_buf_get_name(0)

  if not bufname or bufname == "" then
    return "[No Name]"
  end

  return vim.fn.fnamemodify(bufname, ":.")
end

local function modified()
  return "[+]"
end

local function readonly()
  return "[-]"
end

require("lualine").setup({
  options = {
    icons_enabled = false,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = {
      {
        "mode",
      },
    },
    lualine_b = {
      {
        fugitivestatusline,
      },
    },
    lualine_c = {
      {
        filename,
      },
      {
        modified,
        cond = function()
          return vim.bo.modified
        end,
        padding = { left = 0, right = 1 },
      },
      {
        readonly,
        padding = { left = 0, right = 1 },
        cond = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
      },
    },
    lualine_x = {
      {
        "diagnostics",
      },
      {
        "fileformat",
      },
      {
        "filetype",
      },
    },
    lualine_y = {},
    lualine_z = {
      {
        "%l:%L",
        type = "stl",
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      {
        fugitivestatusline,
      },
    },
    lualine_c = {
      {
        filename,
      },
      {
        modified,
        cond = function()
          return vim.bo.modified
        end,
        padding = { left = 0, right = 1 },
      },
      {
        readonly,
        padding = { left = 0, right = 1 },
        cond = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      "filetype",
    },
  },
  extensions = {
    "fugitive",
    {
      sections = {
        lualine_a = {
          {
            "%q",
            type = "stl",
          },
        },
        lualine_b = {
          {
            "w:quickfix_title",
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "%l/%L",
            type = "stl",
          },
        },
      },
      filetypes = { "qf" },
    },
    {
      sections = {
        lualine_a = {
          {
            function()
              return string.format("%d args", #vim.fn.argv())
            end,
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      filetypes = { "dirvish" },
    },
  },
})
