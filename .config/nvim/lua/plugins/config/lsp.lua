-- {{{ cmp

vim.cmd("packadd! nvim-cmp")
vim.cmd("packadd! cmp-nvim-lsp")
vim.cmd("packadd! cmp-path")
vim.cmd("packadd! cmp-buffer")
vim.cmd("packadd! cmp-vsnip")
vim.cmd("packadd! vim-vsnip")
vim.cmd("packadd! nvim-lspconfig")
vim.cmd("packadd! fidget.nvim")
vim.cmd("packadd! nvim-colorizer.lua")

local cmp = require("cmp")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "buffer",  keyword_length = 5 },
    { name = "path" },
  },
})

-- }}}
-- {{{ fidget

local fidget = require("fidget")
fidget.setup()

-- }}}
-- {{{ colorizer

require("colorizer").setup({
  user_default_options = {
    RGB = true,
    RRGGBB = true,
    rgb_fn = true,
    hsl_fn = true,
    names = false,
    tailwind = "lsp",
  },
})

-- }}}
-- {{{ lspconfig

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
})

vim.lsp.enable("ts_ls")
local tsls_default_on_attach = vim.lsp.config.ts_ls.on_attach
vim.lsp.config("ts_ls", {
  on_attach = function(client, bufnr)
    if tsls_default_on_attach then
      tsls_default_on_attach(client, bufnr)
    end

    vim.keymap.set("n", "<M-S-S>", "<cmd>LspTypescriptSourceAction<CR>", {
      buffer = bufnr,
    })

    vim.api.nvim_buf_create_user_command(bufnr, "LspOrganizeImports", function()
      vim.lsp.buf.code_action({
        only = { "source.organizeImports" },
        apply = true,
      })
    end, {})

    vim.keymap.set("n", "<M-S-O>", "<cmd>LspOrganizeImports<CR>", {
      buffer = bufnr,
    })
  end,
  capabilities = cmp_capabilities,
})

vim.lsp.enable("astro")
vim.lsp.config("astro", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("html")
vim.lsp.config("html", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("cssls")
vim.lsp.config("cssls", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("jsonls")
vim.lsp.config("jsonls", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("tailwindcss")
vim.lsp.config("tailwindcss", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

vim.lsp.enable("eslint")
vim.lsp.config("eslint", {
  capabilities = cmp_capabilities,
})

vim.lsp.enable("efm")
vim.lsp.config("efm", {
  filetypes = {
    "sh",
    "vim",
    "lua",
    "yaml",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
})

-- }}}
-- {{{ keymaps

local format_on_save_autocmds = vim.api.nvim_create_augroup("FormatOnSave", {
  clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local opts = { buffer = ev.buf }

    if client:supports_method("textDocument/formatting") then
      local function format(options)
        local default_filter = function(c)
          return c.name ~= "ts_ls" and c.name ~= "cssls" and c.name ~= "html"
        end

        vim.lsp.buf.format({
          async = false,
          timeout_ms = 500,
          filter = function(c)
            if options and options.filter then
              return default_filter(c) and options.filter(c)
            end

            return default_filter(c)
          end,
        })
      end

      vim.api.nvim_create_user_command("Fmt", format, {
        nargs = 0,
        desc = "Format document with LSP",
      })

      vim.keymap.set(
        "n",
        "gQ",
        format,
        vim.tbl_extend("force", opts, {
          desc = "Format document with LSP",
        })
      )

      if not client:supports_method("textDocument/willSaveWaitUntil") then
        vim.api.nvim_create_autocmd(
          "BufWritePre",
          vim.tbl_extend("force", opts, {
            group = format_on_save_autocmds,
            command = "Fmt",
          })
        )
      end
    end

    if client:supports_method("textDocument/definition") then
      vim.keymap.set("n", "[d", vim.lsp.buf.definition, opts)

      local function split_definition()
        -- thanks to vim.lsp.buf.definition being tagfunc, we can reuse this
        -- mapping to go definition in a split window
        vim.cmd("normal! ")
      end
      vim.keymap.set("n", "<C-w>d", split_definition, opts)
      vim.keymap.set("n", "<C-w><C-d>", split_definition, opts)
    end

    if client:supports_method("textDocument/typeDefinitionProvider") then
      vim.keymap.set("n", "[t", vim.lsp.buf.type_definition, opts)
    end

    if client:supports_method("textDocument/rename") then
      vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
    end

    if client:supports_method("textDocument/codeAction") then
      vim.keymap.set({ "n", "v" }, "<M-CR>", vim.lsp.buf.code_action, opts)
      vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, opts)
    end

    if client:supports_method("textDocument/references") then
      vim.api.nvim_create_user_command("References", vim.lsp.buf.references, {
        nargs = 0,
        desc = "Populate quickfix list with references of symbol under the cursor",
      })
    end
  end,
})

vim.keymap.set("n", "[g", function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set("n", "]g", function()
  vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set("n", "<C-Space>", vim.diagnostic.open_float)

-- }}}
-- vim: foldmethod=marker foldlevel=999
