-- {{{ cmp

vim.cmd("packadd! nvim-cmp")
vim.cmd("packadd! cmp-nvim-lsp")
vim.cmd("packadd! cmp-path")
vim.cmd("packadd! cmp-buffer")
vim.cmd("packadd! cmp-vsnip")
vim.cmd("packadd! vim-vsnip")
local cmp = require("cmp")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
  }, {
    { name = "buffer", keyword_length = 5 },
    { name = "path" },
  }),
})

-- }}}
-- {{{ fidget

vim.cmd("packadd! fidget.nvim")
local fidget = require("fidget")
fidget.setup()

-- }}}
-- {{{ colorizer

vim.cmd("packadd! nvim-colorizer.lua")
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

vim.cmd("packadd! nvim-lspconfig")
local lspconfig = require("lspconfig")

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local fold_capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
}

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  }
  vim.lsp.buf.execute_command(params)
end

lspconfig.tsserver.setup({
  on_attach = function(_, bufnr)
    vim.keymap.set("n", "<M-S-O>", "<cmd>OrganizeImports<CR>", {
      buffer = bufnr,
    })
  end,
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize imports",
    },
  },
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
})

lspconfig.astro.setup({
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
})

lspconfig.html.setup({
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
})

lspconfig.cssls.setup({
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
})

lspconfig.jsonls.setup({
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
})

lspconfig.tailwindcss.setup({
  capabilities = cmp_capabilities,
})

lspconfig.lua_ls.setup({
  capabilities = vim.tbl_extend("force", cmp_capabilities, fold_capabilities),
  on_init = function(client)
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      },
    })

    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    return true
  end,
})

lspconfig.eslint.setup({
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.efm.setup({
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
-- {{{ handlers

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  signs = false,
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

    local opts = { buffer = ev.buf }

    if client.server_capabilities.hoverProvider then
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end

    if client.server_capabilities.documentFormattingProvider then
      local function format(options)
        local default_filter = function(c)
          return c.name ~= "tsserver"
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

      vim.api.nvim_create_autocmd(
        "BufWritePre",
        vim.tbl_extend("force", opts, {
          group = format_on_save_autocmds,
          callback = function()
            format({
              filter = function(c)
                return c.name ~= "jsonls"
              end,
            })
          end,
          desc = "Format buffer on save using LSP",
        })
      )
    end

    if client.server_capabilities.definitionProvider then
      vim.keymap.set("n", "[d", vim.lsp.buf.definition, opts)

      local function split_definition()
        -- thanks to vim.lsp.buf.definition being tagfunc, we can reuse this
        -- mapping to go definition in a split window
        vim.cmd("normal! ")
      end
      vim.keymap.set("n", "<C-w>d", split_definition, opts)
      vim.keymap.set("n", "<C-w><C-d>", split_definition, opts)
    end

    if client.server_capabilities.typeDefinitionProvider then
      vim.keymap.set("n", "[t", vim.lsp.buf.type_definition, opts)
    end

    if client.server_capabilities.renameProvider then
      vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
    end

    if client.server_capabilities.codeActionProvider then
      vim.keymap.set({ "n", "v" }, "<M-CR>", vim.lsp.buf.code_action, opts)
      vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, opts)
    end

    if client.server_capabilities.referencesProvider then
      vim.api.nvim_create_user_command("References", vim.lsp.buf.references, {
        nargs = 0,
        desc = "Populate quickfix list with references of symbol under the cursor",
      })
    end
  end,
})

vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "<C-Space>", vim.diagnostic.open_float)

-- }}}
-- vim: foldmethod=marker foldlevel=999
