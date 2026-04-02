-- https://github.com/shortcuts/no-neck-pain.nvim
--
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
