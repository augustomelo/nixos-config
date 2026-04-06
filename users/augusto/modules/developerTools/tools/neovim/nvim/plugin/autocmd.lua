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
      { unpack(default_opts), desc = "vim.lsp.buf.declaration()" })
    vim.keymap.set("n", "grdf", vim.lsp.buf.definition,
      { unpack(default_opts), desc = "vim.lsp.buf.definition()" })
    vim.keymap.set("n", "grih",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf, })) end,
      { unpack(default_opts), desc = "vim.lsp.inlay_hint()" })
  end
})

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value or {}
    if not value.kind then return end

    local status = value.kind == "end" and 0 or 1
    local percent = value.percentage or 0

    local osc_seq = string.format("\27]9;4;%d;%d\a", status, percent)

    if os.getenv("TMUX") then
      osc_seq = string.format("\27Ptmux;\27%s\27\\", osc_seq)
    end

    io.stdout:write(osc_seq)
    io.stdout:flush()
  end,
})
