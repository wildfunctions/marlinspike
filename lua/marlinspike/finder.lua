local Path = require("plenary.path")

local harpoon_config_file = string.format("%s/harpoon.json", vim.fn.stdpath("data"))

local function read_json_file(file)
    return vim.json.decode(Path:new(file):read())
end

local function is_git_repo(path)
  local uv = vim.loop
  local git_path = path .. "/.git"
  local stat = uv.fs_stat(git_path)

  if stat and stat.type == "directory" then
    return true
  end

  return false
end

local function find_git_repo_root()
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

local function get_harpoon_projects()
  local ok, module = pcall(require, "harpoon")
  if not ok then
    return {}
  end

  local ok2, harpoon_config = pcall(read_json_file, harpoon_config_file)
  if not ok2 then
    -- print("Error reading config file: ", harpoon_config_file)
    return {}
  end

  return harpoon_config["projects"]
end

local function find_unknown_projects()
  local uv = vim.loop
  local paths_with_git = {}

  local harpoon_projects = get_harpoon_projects()
  if harpoon_projects ~= nil then
    for key, _ in pairs(harpoon_projects) do
      if is_git_repo(key) then
        table.insert(paths_with_git, key)
      end
    end
  end

  return paths_with_git
end

return {
  find_unknown_projects = find_unknown_projects,
  find_git_repo_root = find_git_repo_root
}
