vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/alexghergh/nvim-tmux-navigation",
  "https://github.com/chaoren/vim-wordmotion",
  "https://github.com/jellydn/hurl.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope-file-browser.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/olrtg/nvim-emmet",
  "https://github.com/rachartier/tiny-cmdline.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/tpope/vim-repeat",
  "https://github.com/tpope/vim-surround",
  "https://github.com/windwp/nvim-autopairs",
  { src = "https://github.com/catppuccin/nvim",               name = "catppuccin" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("0.2.x") },
  { src = "https://github.com/obsidian-nvim/obsidian.nvim",   version = vim.version.range("3.x") },
  { src = "https://github.com/saghen/blink.cmp",              version = vim.version.range("1.x") },
  { src = "https://github.com/shortcuts/no-neck-pain.nvim",   version = vim.version.range("2.x") },
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
