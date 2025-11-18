local servers = {
  -- https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
  bashls = {},

  -- https://github.com/olrtg/emmet-language-server
  emmet_language_server = {
    filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact" },
  },

  -- https://pkg.go.dev/golang.org/x/tools/gopls#readme-configuration
  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          ST1000 = false,
        },
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

  -- https://github.com/grafana/jsonnet-language-server
  jsonnet_ls = {},

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
        nix = {
          flake = {
            autoArchive = true,
          },
        },
      },
    },
  },

  -- https://github.com/hashicorp/terraform-ls/blob/main/docs/SETTINGS.md
  terraformls = {},

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
            extendSelect = { "I", "N" },
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

  -- https://vale.sh/docs/guides/lsp
  vale_ls = {
    filetypes = { "gitcommit", "jjdescription", "markdown", "text" },
    init_options = {
      installVale = false,
      syncOnStartup = true,
      configPath = vim.env.XDG_CONFIG_HOME .. "/vale/vale.ini"
    },
    root_dir = function(_, on_dir)
      on_dir(vim.fn.getcwd())
    end,
    on_new_config = function(new_config, _)
      if vim.fn.findfile(".vale.ini", ".;") ~= "" then
        new_config.init_options.configPath = vim.fn.getcwd() .. "/.vale.ini"
      end
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
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
