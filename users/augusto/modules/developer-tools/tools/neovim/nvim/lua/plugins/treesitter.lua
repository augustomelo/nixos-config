return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context"
  },
  build = ":TSUpdate",
}
