local fugitivestatusline = {
  function()
    local fugitive = vim.fn["FugitiveStatusline"]()

    local file_revision = string.match(fugitive, "Git:(.+)%(")
    local checked_out_branch = string.match(fugitive, "Git%((.+)%)")

    if file_revision == "0" then
      return "index"
    end

    return file_revision or checked_out_branch or ""
  end,
  icon = { "" },
}

local filename = {
  function()
    local fullpath = vim.fn.expand("%:p")
    local fname = vim.fn.expand("%:t")

    if fname == "" then
      return "[No Name]"
    end

    return fname
  end,
  padding = { left = 1, right = 1 },
}

local modified = {
  function()
    return "[+]"
  end,
  cond = function()
    return vim.bo.modified
  end,
  padding = { left = 0, right = 1 },
}

local readonly = {
  function()
    return "[-]"
  end,
  cond = function()
    return not vim.bo.modifiable or vim.bo.readonly
  end,
  padding = { left = 0, right = 1 },
}

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
      fugitivestatusline,
      "g:coc_status",
      "g:async_make_status",
    },
    lualine_c = {
      filename,
      modified,
      readonly,
    },
    lualine_x = { "diagnostics", "fileformat", "filetype" },
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
    lualine_b = {},
    lualine_c = {
      filename,
      modified,
      readonly,
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      "filetype",
    },
  },
  extensions = {
    "quickfix",
    "fugitive",
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
