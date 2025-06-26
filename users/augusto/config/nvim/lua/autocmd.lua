vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "*",
  command = "setlocal cursorline",
  group = vim.api.nvim_create_augroup("CursorLine", { clear = true })
})

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  pattern = "*",
  command = "setlocal nocursorline",
  group = vim.api.nvim_create_augroup("CursorLine", { clear = false })
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP attach keymaps",
  callback = function(args)
    local default_opts = { noremap = true, silent = true, buffer = args.buf }

    vim.keymap.set("n", "grdc", vim.lsp.buf.declaration,
      { unpack(default_opts), desc = "vim.lsp.buf.declaration" })
    vim.keymap.set("n", "grdf", vim.lsp.buf.definition,
      { unpack(default_opts), desc = "vim.lsp.buf.definition" })
    vim.keymap.set("n", "grtd", vim.lsp.buf.type_definition,
      { unpack(default_opts), desc = "vim.lsp.buf.type_definition" })
    vim.keymap.set("n", "<leader>ih",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf, })) end,
      { unpack(default_opts), desc = "vim.lsp.inlay_hint" })
  end
})
