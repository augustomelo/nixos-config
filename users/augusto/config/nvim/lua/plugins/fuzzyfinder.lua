return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.x",
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
