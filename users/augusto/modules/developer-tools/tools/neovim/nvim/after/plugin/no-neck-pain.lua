-- https://github.com/shortcuts/no-neck-pain.nvim?tab=readme-ov-file#-configuration
require("no-neck-pain").setup({
  width = 150,
  mappings = {
    enabled = true,
    toggle = "<Leader>np",
  },
  buffers = {
    bo = { number = true, relativenumber = true },
  },
})
