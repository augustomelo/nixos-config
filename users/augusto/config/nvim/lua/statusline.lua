-- colors based on catpuccin macchiato color pallet
-- https://catppuccin.com/palette
local init_colors = function()
  vim.api.nvim_set_hl(0, "Statusline", { fg = "#cad3f5", bg = "#24273a" })
  vim.api.nvim_set_hl(0, "StatuslineSeparator", { fg = "#494d64", bg = "#494d64" })
end

local base_color = function()
  return "%#Statusline#"
end

local separator_color = function()
  return "%#StatuslineSeparator#"
end

local create_group = function()
  return "%="
end

local render_sep = function(sep)
  if sep ~= nil and sep ~= "" then
    return string.format("%s%s%s", separator_color(), sep, base_color())
  end

  return ""
end

local render = function(lsep, producer, rsep)
  local info = producer()

  if info ~= nil and info ~= "" then
    return string.format("%s %s %s", render_sep(lsep), info, render_sep(rsep))
  end

  return ""
end

local git_branch = function()
  local branch_name = vim.fn.system("git branch --show-current 2> /dev/null | tr -d \"\n\"")

  if string.len(branch_name) > 0 then
    return string.format("%s  ", branch_name)
  else
    return ""
  end
end

local cwd = function()
  local split_cwd = vim.split(vim.fn.getcwd(), "/")
  return split_cwd[#split_cwd]
end

local buffer_encoding = function()
  if vim.bo.fileencoding == nil or vim.bo.fileencoding == "" then
    return vim.o.encoding
  else
    return vim.bo.fileencoding
  end
end

local recording_info = function()
  local register = vim.fn.reg_recording()

  if register ~= nil and register ~= "" then
    return string.format("recording @%s", register)
  else
    return ""
  end
end

local pos_info = function()
  local v_column_number = "%3v"
  local current_line = vim.fn.line(".")
  local total_lines = "%-4L"
  return string.format("%s:%s/%s", v_column_number, current_line, total_lines)
end

local table_contains = function(tbl, x)
  for _, v in pairs(tbl) do
    if v == x then
      return true
    end
  end

  return false
end

local lsp_name = function()
  local buff_clients = vim.lsp.get_clients({buffer=0})

  if buff_clients ~=nil then
    for _, client in pairs(buff_clients) do
      if table_contains(client.config.filetypes, vim.bo.filetype) then
        return client.name
      end
    end
  end

  return ""
end

local file_format = function()
  return vim.o.fileformat
end

local search_count = function()
  local search = vim.fn.searchcount({maxcount = 0}) -- maxcount = 0 makes the number not be capped at 99
  local current = search.current

  if current ~= nil and  current > 0 then
    return "/"..vim.fn.getreg("/").." ["..current.."/"..search.total.."]"
  end

  return ""
end

local M = {}

M.statusline = function()
  init_colors()

  local parts = {
    { left = "", info = base_color, right = "" },
    { left = "", info = cwd, right = "▊" },
    { left = "", info = git_branch, right = "▊" },
    { left = "", info = recording_info, right = "" },
    { left = "", info = create_group, right = "" },
    { left = "", info = create_group, right = "" },
    { left = "▊", info = search_count, right = "" },
    { left = "▊", info = lsp_name, right = "" },
    { left = "▊", info = file_format, right = "" },
    { left = "▊", info = buffer_encoding, right = "" },
    { left = "▊", info = pos_info, right = "" },
  }

  local statusline = ""

  for _, v in pairs(parts) do
    statusline = statusline .. render(v.left, v.info, v.right)
  end

  return statusline
end

return M
