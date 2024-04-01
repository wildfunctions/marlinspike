local is_file_in_folder = require("marlinspike.utils").is_file_in_folder

local function new_entry_object()
  local entry = {
    writes = 1,
    date = os.date()
  }

  return entry
end

local function ensure_exists(projects, project)
  if not projects[project] then
    projects[project] = new_entry_object()
  end
end


local function bump_entry(projects, project)
  ensure_exists(projects, project)

  local entry = projects[project]
  entry.writes = entry.writes + 1
  entry.date = os.date()

  projects[project] = entry
end

local function bump_project(projects, saved_file)
  local project_of_file = ""

  for project, _ in pairs(projects) do
    if is_file_in_folder(saved_file, project) then
      project_of_file = project
      break
    end
  end

  if project_of_file == "" then
    return projects, "Could not find project for file: " .. saved_file
  end

  bump_entry(projects, project_of_file)

  return projects, nil
end

return {
  bump_project = bump_project,
  ensure_exists = ensure_exists
}
