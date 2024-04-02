local config = require("marlinspike.config")
local finder = require("marlinspike.finder")
local ui = require("marlinspike.ui")

local projects = {}
local sortedProjects = {}
local currentBuffer = vim.api.nvim_buf_get_name(0)
local currentProjectIndex = 1

local winId = nil
local winBuf = nil

function addProject()
  local project = finder.findGitRepoRoot()
  if project ~= "" then
    config.ensureExists(projects, project)
  end
end

function loadNext()
  currentProjectIndex = (currentProjectIndex  % #sortedProjects) + 1
  local next_project = sortedProjects[currentProjectIndex]
  local project = projects[next_project]
  if project ~= nil then
    vim.cmd("cd " .. next_project)
    vim.loop.chdir(next_project)
    print("Current working directory: ", vim.fn.getcwd())
  end
end

function loadByIndex(index)
  local next_project = sortedProjects[index]
  local project = projects[next_project]
  if project ~= nil then
    vim.cmd("cd " .. next_project)
    vim.loop.chdir(next_project)
    print("Current working directory: ", vim.fn.getcwd())
  end
end

function closeMenu(selectProject)
  local currentLine = vim.fn.line(".")

  ui.closeMenu(winId)
  winId = nil
  winBuf = nil
  if selectProject then
    loadByIndex(currentLine)
  end
end


local function openMenu()
  if winId ~= nil then
    local isMenuOpen = vim.api.nvim_win_is_valid(winId)
    closeMenu(false)
    if isMenuOpen then
      return
    end
  end
  local menu = ui.createMenu(sortedProjects)
  winId = menu.winId
  winBuf = menu.bufnr
  vim.api.nvim_buf_set_keymap(winBuf, "n", "<CR>", "<Cmd>lua closeMenu(true)<CR>", {silent = true})
end

local function setDefaultKeymaps()
  vim.keymap.set("n", "<leader>ma", function() addProject() end, {noremap = true, silent = true})
  vim.keymap.set("n", "<leader>mn", function() loadNext() end, {noremap = true, silent = true})

  vim.keymap.set("n", "<leader>me", function() openMenu() end, {noremap = true, silent = true})
end

local function onSave()
  local currentFilePath = vim.api.nvim_buf_get_name(0)
  local _projects, err = config.bumpProject(projects, currentFilePath)
  if err == nil then
    projects = _projects
  end

  -- if err ~= nil then
  --   print("Error bumping project: ", err)
  -- end
end

local function init()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = onSave
  })

  setDefaultKeymaps()

  local unknownProjects = finder.findUnknownProjects()
  for i = 1, #unknownProjects do
    config.ensureExists(projects, unknownProjects[i])
  end

  for key, _ in pairs(projects) do
    table.insert(sortedProjects, key)
  end

  local _projects, err = config.bumpProject(projects, currentBuffer)

  currentBuffer = vim.api.nvim_buf_get_name(0)

  print(#sortedProjects .. " projects loaded")
end

local function printProjects()
  print(vim.inspect(projects))
end

return {
  init = init,
  printProjects = printProjects,
  addProject = addProject,
  loadNext = loadNext,
  openMenu = openMenu
}
