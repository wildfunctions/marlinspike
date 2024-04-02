local isFileInFolder = require("marlinspike.utils").isFileInFolder

local function newEntryObject()
  local entry = {
    writes = 1,
    time = os.time()
  }

  return entry
end

local function ensureProjectExists(projects, project)
  if not projects[project] then
    projects[project] = newEntryObject()
  end
end


local function bumpEntry(projects, project)
  ensureProjectExists(projects, project)

  local entry = projects[project]
  entry.writes = entry.writes + 1
  entry.time = os.time()

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

local function entryScore(entry)
  -- suppose you save a file every 10 seconds, so 6 times a second
  -- after an 8 hour work week, that's 6 * 60 * 8 * 5 = 14400 saves
  -- after a year, that's 14400 * 52 = 748800 saves
  --
  -- dates are more aggressive, after a week, that's 60 * 60 * 24 * 7 = 604800 seconds
  -- after a year, that's 604800 * 52 = 31449600 seconds
  --
  -- So maybe 748800 / 31449600 = 0.0238 would be a good time multiplier

  local dateScore = (os.time() - entry.time) * .0238
  local score = entry.writes - dateScore
  return score
end

local function sortProjects(projectsArray)
  table.sort(projectsArray, function(a, b)
    return entryScore(a) > entryScore(b)
  end)
end

return {
  bumpProject = bumpProject,
  ensureProjectExists = ensureProjectExists,
  sortProjects = sortProjects
}
