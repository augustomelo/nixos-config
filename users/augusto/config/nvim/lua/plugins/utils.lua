return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
  },
  {
    "j-hui/fidget.nvim",
    tag = "v1.4.5",
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
    version = "3.7.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
  },
}
