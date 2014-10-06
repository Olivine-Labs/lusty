local loaded = {}

local function loadModule(name)
  local errors = {}
  -- Find source
  local modulePath = string.gsub(name, "%.", "/")
  for path in string.gmatch(package.path, "([^;]+)") do
    local fileName = string.gsub(path, "%?", modulePath)
    local file = io.open(fileName, "rb")
    if file then
      return file:read("*a")
    end
    errors[#errors+1] = "\n\tno file '"..fileName.."' (attempted with lusty inline)"
  end
  return nil, table.concat(errors)
end

--load file, memoize, execute loaded function inside environment
local function inline(name, env)
  local file = loaded[name]
  if not file then
    local code, err = loadModule(name)
    if not code then
      error(err)
    end
    local keys ={}
    for k in pairs(env) do
      keys[#keys+1] = k
    end

    if #keys > 0 then
      file, err = loadstring(
        'local _env=select(1, ...)\nlocal '..table.concat(keys, ',')..
        "=_env."..table.concat(keys, ",_env.")..
        '\n'..code
      )
    else
      file, err = loadstring(code)
    end
    if not file then error(err) end
    loaded[name] = file
  end
  return file(env)
end

local function clearCache()
  loaded = {}
end

return {
  inline = inline,
  clearCache = clearCache,
}
