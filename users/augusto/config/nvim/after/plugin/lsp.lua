local lspconfig = require("lspconfig")
local servers = {
  -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        gofumpt = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        staticcheck = true,
      },
    },
  },

  -- https://github.com/mrjosh/helm-ls?tab=readme-ov-file#configuration-options
  helm_ls = {
    settings = {
      ["helm-ls"] = {
        yamlls = {
          path = "yaml-language-server",
        },
      },
    },
  },

  -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  jdtls = {
    settings = {
      java = {
        autobuild = {
          enabled = false,
        },
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
      },
    },
  },

  -- https://github.com/LuaLS/lua-language-server/wiki/Settings#settings
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        hint = {
          enable = true
        },
        runtime = {
          version = "LuaJIT",
        },
        telemetry = {
          enable = false,
        },
        workspace = {
          library = {
            vim.env.VIMRUNTIME,
          }
        },
      },
    },
  },

  -- https://github.com/oxalica/nil/blob/main/docs/configuration.md
  nil_ls = {
    settings = {
      ['nil'] = {
        formatting = {
          command = { "nixfmt" },
        },
      },
    },
  },

  -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pylsp_mypy = {
            enabled = true,
          },
          rope_autoimport = {
            enabled = true,
          },
          ruff = {
            enabled = true,
            extendSelect = { "I" },
          },
        },
      },
    },
  },

  -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
  ts_ls = {
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
        },
      },
    },
  },

  -- https://github.com/errata-ai/vale-ls/tree/main/doc/yml
  vale_ls = {
    filetypes = { "gitcommit", "markdown", "text" },
    init_options = {
      installVale = false,
      syncOnStartup = false,
    },
    root_dir = function(_)
      return vim.fn.getcwd()
    end,
    on_new_config = function(new_config, _)
      local config_path = vim.fn.findfile(".vale.ini", ".;")

      if config_path == "" then
        config_path = vim.env.XDG_CONFIG_HOME .. "/vale/vale.ini"
      else
        config_path = vim.fn.getcwd() .. "/.vale.ini"
      end

      new_config.init_options.configPath = config_path
    end,
  },

  -- https://github.com/redhat-developer/yaml-language-server?tab=readme-ov-file#language-server-settings
  yamlls = {
    on_attach = function(client, _)
      client.server_capabilities.documentFormattingProvider = true
    end,
    settings = {
      yaml = {
        format = {
          enable = true,
        },
        validate = true,
        completion = true
      }
    }
  },
}

for server, config in pairs(servers) do
  lspconfig[server].setup(vim.tbl_extend("force", config, {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }))
end
