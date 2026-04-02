vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
  { src = "https://github.com/catppuccin/nvim",                           name = "catppuccin" },
  { src = "https://github.com/chaoren/vim-wordmotion" },
  { src = "https://github.com/j-hui/fidget.nvim",                         version = vim.version.range("1.x") },
  { src = "https://github.com/jellydn/hurl.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-file-browser.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim",             version = vim.version.range("0.2.x") },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
  { src = "https://github.com/obsidian-nvim/obsidian.nvim",               version = vim.version.range("3.x") },
  { src = "https://github.com/saghen/blink.cmp",                          version = vim.version.range("1.x") },
  { src = "https://github.com/shortcuts/no-neck-pain.nvim",               version = vim.version.range("2.x") },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/tpope/vim-repeat" },
  { src = "https://github.com/tpope/vim-surround" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/olrtg/nvim-emmet" },
})

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    elseif name == "telescope-fzf-native.nvim" and kind == "install" or kind == "update" then
      if not ev.data.active then vim.cmd.packadd("telescope-fzf-native.nvim") end
      vim.cmd("make")
    end
  end
})
