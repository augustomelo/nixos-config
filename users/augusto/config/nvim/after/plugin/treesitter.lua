require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "c",
    "go",
    "gomod",
    "java",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
    "yaml",
  },

  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    true
  },
})

-- Fold is currently broken:
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1424
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337
-- https://github.com/neovim/neovim/issues/14977
--vim.opt.foldmethod = "expr"
--vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldmethod = "indent"
