local config = require("marlinspike.config")
local finder = require("marlinspike.finder")

local projects = {}
local sorted_projects = {}
local current_buffer = vim.api.nvim_buf_get_name(0)
local current_project_index = 1

local function on_save()
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

function load_next()
  current_project_index = (current_project_index  % #sorted_projects) + 1
  local next_project = sorted_projects[current_project_index]
  local project = projects[next_project]
  if project ~= nil then
    vim.cmd("cd " .. next_project)
    print("Changed project to: ", vim.fn.getcwd())
  end
end

local function keybinds()
  vim.keymap.set("n", "<leader>ma", "<cmd>lua add_project()<CR>", {noremap = true, silent = true})
  vim.keymap.set("n", "<leader>mn", "<cmd>lua load_next()<CR>", {noremap = true, silent = true})
end

local function init()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = on_save
  })

  keybinds()

  local unknown_projects = finder.find_unknown_projects()
  for i = 1, #unknown_projects do
    config.ensure_exists(projects, unknown_projects[i])
  end

  for key, _ in pairs(projects) do
      table.insert(sorted_projects, key)
  end

  local _projects, err = config.bump_project(projects, current_buffer)

  current_buffer = vim.api.nvim_buf_get_name(0)

  print(#sorted_projects .. " projects loaded")
end

local function print_projects()
  print(vim.inspect(projects))
end

return {
  init = init,
  print_projects = print_projects
}
