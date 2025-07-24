return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
  },
  {
    "j-hui/fidget.nvim",
    version = "1.6.x",
  },
  {
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    ft = "hurl",
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "2.4.x",
  },
  { "alexghergh/nvim-tmux-navigation" },
  {
    "epwalsh/obsidian.nvim",
    version = "3.9.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
