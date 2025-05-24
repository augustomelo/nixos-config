return {
  "nvim-treesitter/nvim-treesitter",
  -- Leving out the branch on purpose, because when the default become main it
  -- will break my config. The new branch has lot of breaking changes like it
  -- was removed "nvim-treesitter.config" and the way of enabling highlight it
  -- will be different
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/2293
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context"
  },
  build = ":TSUpdate",
}
