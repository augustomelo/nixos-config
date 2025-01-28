require("telescope").setup({
  extensions = {
    file_browser = {
      hijack_netrw = true,
      hidden = {
        file_browser = true,
        folder_browser = true
      },
      mappings = {
        i = {
          ["<A-e>"] = require("telescope").extensions.file_browser.actions.rename,
        },
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
    buffers = {
      ignore_current_buffer = true,
      sort_lastused = true,
    },
  },
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--follow",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--trim",
    },
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
})

require("telescope").load_extension("file_browser")

local builtin = require("telescope.builtin")
local default_opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>ff", builtin.find_files,
  { unpack(default_opts), desc = "Find file on the current working directory." })
vim.keymap.set("n", "<leader>fs", builtin.live_grep,
  { unpack(default_opts), desc = "Live grep on the current working directory." })
vim.keymap.set("n", "<leader>*", builtin.grep_string,
  { unpack(default_opts), desc = "Searches for the string in the current working directory." })
vim.keymap.set("n", "<leader>fb", builtin.buffers,
  { unpack(default_opts), desc = "Find open buffers." })

vim.keymap.set("n", "<C-n>", function()
  require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true })
end, { unpack(default_opts), desc = "File browser based on the selected buffer" })
