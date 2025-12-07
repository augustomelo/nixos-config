return {
  "nvim-telescope/telescope.nvim",
  version = "0.2.x",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  { "nvim-tree/nvim-web-devicons" },
}
