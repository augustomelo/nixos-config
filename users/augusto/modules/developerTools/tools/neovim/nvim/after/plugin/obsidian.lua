require("obsidian").setup({
  completion = {
    nvim_cmp = false,
    blink = true,
  },
  legacy_commands = false,
  workspaces = {
    {
      name = "notes",
      path = "~/workspace/personal/notes",
    },
  },
})
