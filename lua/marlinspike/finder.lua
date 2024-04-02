local Path = require("plenary.path")

local harpoonConfigFile = string.format("%s/harpoon.json", vim.fn.stdpath("data"))

local function readJsonFile(file)
    return vim.json.decode(Path:new(file):read())
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

local function findGitRepoRoot()
  local current_buffer = vim.api.nvim_buf_get_name(0)

  -- Use git to find the root directory of the repo
  --
  -- git rev-parse --show-toplevel
  local git_cmd = "git rev-parse --show-toplevel"
  local result = vim.fn.system(git_cmd)

  -- vim.fn.system returns the command output including a trailing newline, so we trim it
  result = string.gsub(result, "[\n\r]+$", "")

  -- Check for error in result. If git command fails, it usually returns a non-zero exit code and an error message.
  if vim.v.shell_error ~= 0 then
    print("Error finding Git root: " .. result)
    return nil
  end

  return result
end

local function getHarpoonProjects()
  local ok, module = pcall(require, "harpoon")
  if not ok then
    return {}
  end

  local ok2, harpoonConfig = pcall(readJsonFile, harpoonConfigFile)
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
      if isGitRepo(key) then
        table.insert(pathsWithGit, key)
      end
    end
  end

  return pathsWithGit
end

return {
  findUnknownProjects = findUnknownProjects,
  findGitRepoRoot = findGitRepoRoot
}
