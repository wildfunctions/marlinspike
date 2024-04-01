local config = require("marlinspike.config")
local finder = require("marlinspike.finder")

local projects = {}
local current_buffer = vim.api.nvim_buf_get_name(0)

local function on_save()
  print("Current projects in add.... closure???: ", vim.inspect(projects))
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local _projects, err = config.bump_project(projects, current_file_path)
  if err == nil then
    projects = _projects
  end

  -- if err ~= nil then
  --   print("Error bumping project: ", err)
  -- end
end

function add_project()
  local project = finder.find_git_repo_root()
  if project ~= "" then
    config.ensure_exists(projects, project)
  end
end

local function keybinds()
  vim.keymap.set("n", "<leader>ma", "<cmd>lua add_project()<CR>", {noremap = true, silent = true})
end

local function init()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = on_save
  })

  keybinds()

  -- local unknown_projects = finder.find_unknown_projects()
  -- for i = 1, #unknown_projects do
  --   config.ensure_exists(projects, unknown_projects[i])
  -- end
  -- print("loaded unknown projects ", vim.inspect(unknown_projects))

  -- vim.cmd("cd " .. projects[1])
  -- vim.cmd("redraw!")
  -- print("Changed directory to: ", vim.fn.getcwd())
  --
  local _projects, err = config.bump_project(projects, current_buffer)

  current_buffer = vim.api.nvim_buf_get_name(0)

  print("Marlinspike Projects: ", vim.inspect(projects))
end

local function print_projects()
  print(vim.inspect(projects))
end

return {
  init = init,
  print_projects = print_projects
}
