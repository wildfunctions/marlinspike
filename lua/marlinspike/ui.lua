local popup = require("plenary.popup")

local function createMenu(projects)
  if projects == nil then
    projects = {}
  end

  local opts = {}
  for i, project in ipairs(projects) do
    opts[i] = project.name
  end

  local height = 20
  local width = 50
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local winId = popup.create(opts, {
    title = "Marlinspike Projects",
    highlight = "Marlinspike",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })
  local bufnr = vim.api.nvim_win_get_buf(winId)

  return {
    winId = winId,
    bufnr = bufnr
  }
end

local function closeMenu(winId)
  if vim.api.nvim_win_is_valid(winId) then
    vim.api.nvim_win_close(winId, true)
  end
end

return {
  createMenu = createMenu,
  closeMenu = closeMenu
}
