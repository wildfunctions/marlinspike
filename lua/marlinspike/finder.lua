local utils = require("marlinspike.utils")

local harpoonConfigFile = string.format("%s/harpoon.json", vim.fn.stdpath("data"))

--- Get the root directory of the project by using the git command
--- If the git command fails then use the current working directory
---@return string | nil
local function getProjectRoot(config)
  local cwd = vim.loop.cwd()
  if config.useGitRoot then
    local root = vim.fn.system("git rev-parse --show-toplevel")
    if vim.v.shell_error == 0 and root ~= nil then
      local path = string.gsub(root, "\n", "")
      path = string.gsub(path, "[\n\r]+$", "")
      return path
    end
  end
  return cwd
end

local function isGitRepo(path)
  local uv = vim.loop
  local git_path = path .. "/.git"
  local stat = uv.fs_stat(git_path)

  if stat and stat.type == "directory" then
    return true
  end

  return false
end

local function getHarpoonProjects()
  local ok, module = pcall(require, "harpoon")
  if not ok then
    return {}
  end

  local ok2, harpoonConfig = pcall(utils.readJsonFile, harpoonConfigFile)
  if not ok2 then
    return {}
  end

  return harpoonConfig
end

local function findUnknownProjects()
  local uv = vim.loop
  local pathsWithGit = {}

  local harpoonProjects = getHarpoonProjects()
  if harpoonProjects ~= nil then
    for key, _ in pairs(harpoonProjects) do
      -- TODO: make this configurable
      -- why is my harpoon is full of junk that aren't git repos
      if isGitRepo(key) then
        table.insert(pathsWithGit, key)
      end
    end
  end

  return pathsWithGit
end

return {
  findUnknownProjects = findUnknownProjects,
  getProjectRoot = getProjectRoot,
}
