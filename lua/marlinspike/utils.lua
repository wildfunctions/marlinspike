
local Path = require("plenary.path")

local function isFileInFolder(file, folder)
  local filePath = Path:new(file):absolute()
  local folderPath = Path:new(folder):absolute()

  local sub = filePath:sub(1, #folderPath)
  return sub == tostring(folderPath)
end

return {
  isFileInFolder = isFileInFolder
}
