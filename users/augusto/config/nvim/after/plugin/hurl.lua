require("hurl").setup({
  formatters = {
    json = { "dasel", "--read", "json" },
    html = {}
  }
})
