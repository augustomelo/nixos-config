-- https://github.com/obsidian-nvim/obsidian.nvim

require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "notes",
      path = "~/workspace/personal/notes",
    },
  },
})
