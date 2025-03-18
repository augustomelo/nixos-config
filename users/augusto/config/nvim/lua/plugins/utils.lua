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
    "epwalsh/obsidian.nvim",
    version = "3.9.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "2.2.x",
  },
}
