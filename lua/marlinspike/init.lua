local state = require("marlinspike.state")
local finder = require("marlinspike.finder")
local ui = require("marlinspike.ui")
local utils = require("marlinspike.utils")

-- speed over memory footprint
local projectsMap = {}
local sortedProjectsArray = {}

local currentBuffer = nil
local currentProjectIndex = 1
local configFile = string.format("%s/marlinspike.json", vim.fn.stdpath("data"))

local winId = nil
local winBuf = nil

local defaults = {
  autoInit = true,
  useDefaultKeymaps = true,
  useGitRoot = true,
  debug = false
}
local config = {}

local function buildSortedProjectsList()
  sortedProjectsArray = {}
  for key, value in pairs(projectsMap) do
    local element = utils.shallowClone(value)
    element.name = key
    table.insert(sortedProjectsArray, element)
  end
  state.sortProjects(sortedProjectsArray)
end

local function saveProjects()
  utils.writeJsonFile(configFile, projectsMap)
  buildSortedProjectsList()
end

function AddProject()
  local projectRoot = finder.getProjectRoot(config)
  if projectRoot == nil then
    print("Could not find project root")
    return
  end

  state.ensureProjectExists(projectsMap, projectRoot)
  saveProjects()
end

function LoadNext()
  currentProjectIndex = (currentProjectIndex  % #sortedProjectsArray) + 1
  local nextProject = sortedProjectsArray[currentProjectIndex].name
  local project = projectsMap[nextProject]
  if project ~= nil then
    vim.cmd("cd " .. nextProject)
    vim.loop.chdir(nextProject)
    print("Current working directory: ", vim.fn.getcwd())
  end
end

function LoadByIndex(index)
  local nextProject = sortedProjectsArray[index].name
  local project = projectsMap[nextProject]
  if project ~= nil then
    vim.cmd("cd " .. nextProject)
    vim.loop.chdir(nextProject)
    print("Current working directory: ", vim.fn.getcwd())
  end
end

function CloseMenu(selectProject)
  local currentLine = vim.fn.line(".")

  ui.closeMenu(winId)
  winId = nil
  winBuf = nil
  if selectProject then
    LoadByIndex(currentLine)
  end
end

local function openMenu()
  if winId ~= nil then
    local isMenuOpen = vim.api.nvim_win_is_valid(winId)
    CloseMenu(false)
    if isMenuOpen then
      return
    end
  end
  local menu = ui.createMenu(sortedProjectsArray)
  winId = menu.winId
  winBuf = menu.bufnr
  vim.api.nvim_buf_set_keymap(winBuf, "n", "<CR>", "<Cmd>lua CloseMenu(true)<CR>", {silent = true})
end

local function setDefaultKeymaps()
  vim.keymap.set("n", "<leader>ma", function() AddProject() end, {noremap = true, silent = true})
  vim.keymap.set("n", "<leader>mn", function() LoadNext() end, {noremap = true, silent = true})

  vim.keymap.set("n", "<leader>me", function() openMenu() end, {noremap = true, silent = true})
end

local function onSave()
  local currentFilePath = vim.api.nvim_buf_get_name(0)
  local _projects, err = state.bumpProject(projectsMap, currentFilePath)
  if err == nil then
    projectsMap = _projects
    saveProjects()
  end
end

local function init()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = onSave
  })

  if config.useDefaultKeymaps then
    setDefaultKeymaps()
  end

  local projects = utils.readJsonFile(configFile)
  if projects ~= nil then
    projectsMap = projects
  end
  local unknownProjects = finder.findUnknownProjects()
  for i = 1, #unknownProjects do
    state.ensureProjectExists(projectsMap, unknownProjects[i])
  end

  buildSortedProjectsList()
  if config.debug then
    print(#sortedProjectsArray .. " projects loaded")
  end
end

local function printProjects()
  print(vim.inspect(projectsMap))
end

local function setup(userOpts)
  userOpts = userOpts or {}
  config = vim.tbl_deep_extend("force", defaults, userOpts)
  if config.autoInit then
    init()
  end

  if config.debug then
    print("Marlinspike setup with config: ", vim.inspect(config))
  end
end

return {
  setup = setup,
  printProjects = printProjects,
  addProject = AddProject,
  loadNext = LoadNext,
  openMenu = openMenu
}
