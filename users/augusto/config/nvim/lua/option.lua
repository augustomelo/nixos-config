vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.cmdheight = 0
vim.opt.completeopt = "menu,menuone,preview,noinsert,noselect"
vim.opt.expandtab = true
vim.opt.foldenable = false
vim.opt.ignorecase = true
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.listchars = {
  nbsp = "⦸",
  tab = "» ",
  trail = "•",
}
vim.opt.magic = true
vim.opt.messagesopt = "wait:2000,history:500"
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.shiftwidth = 2
vim.opt.showbreak = "⤷ "
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.statusline = "%!v:lua.require(\"statusline\").statusline()"
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.wildignorecase = true
vim.opt.winbar = "%<» %-0.120f%m"

if vim.fn.executable("rg") then
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end
