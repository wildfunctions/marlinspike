local isFileInFolder = require("marlinspike.utils").isFileInFolder

local function newEntryObject()
  local entry = {
    writes = 1,
    date = os.date()
  }

  return entry
end

local function ensureExists(projects, project)
  if not projects[project] then
    projects[project] = newEntryObject()
  end
end


local function bumpEntry(projects, project)
  ensureExists(projects, project)

  local entry = projects[project]
  entry.writes = entry.writes + 1
  entry.date = os.date()

  projects[project] = entry
end

local function bumpProject(projects, saved_file)
  local projectOfFile = ""

  for project, _ in pairs(projects) do
    if isFileInFolder(saved_file, project) then
      projectOfFile = project
      break
    end
  end

  if projectOfFile == "" then
    return projects, "Could not find project for file: " .. saved_file
  end

  bumpEntry(projects, projectOfFile)

  return projects, nil
end

return {
  bumpProject = bumpProject,
  ensureExists = ensureExists
}
