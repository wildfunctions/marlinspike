
local Path = require("plenary.path")

local function is_file_in_folder(file, folder)
  local file_path = Path:new(file):absolute()
  local folder_path = Path:new(folder):absolute()

  local sub = file_path:sub(1, #folder_path)
  return sub == tostring(folder_path)
end

return {
  is_file_in_folder = is_file_in_folder
}
