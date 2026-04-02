require("conform").setup({
  formatters_by_ft = {
    markdown = { "markdownlint" },
  },
})

vim.o.formatexpr = "v:lua.require(\"conform\").formatexpr()"

vim.keymap.set("n", "grf", function()
  require("conform").format({
    async = true,
    lsp_format = "fallback",
  })
end, { noremap = true, silent = true, desc = "conform.format" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
