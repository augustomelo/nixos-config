local ensure_installed = {
  "bash",
  "c",
  "diff",
  "dockerfile",
  "editorconfig",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "helm",
  "hurl",
  "hurl",
  "ini",
  "java",
  "javascript",
  "json",
  "kotlin",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "nix",
  "properties",
  "python",
  "query",
  "requirements",
  "sql",
  "toml",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
local already_installed = require("nvim-treesitter.config").get_installed()
local to_install = vim.iter(ensure_installed)
    :filter(function(parser) return not vim.tbl_contains(already_installed, parser) end)
    :totable()

require("nvim-treesitter").install(to_install)

vim.api.nvim_create_autocmd("FileType", {
  desc = "vim.treesitter.start v:lua.require'nvim-treesitter'.indentexpr v:lua.vim.treesitter.foldexpr",
  callback = function()
    local has_started = pcall(vim.treesitter.start)

    if has_started then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  end,
})
