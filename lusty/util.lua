local loaded = {}
local fileNames = {}

local function loadModule(name)
  local errors = {}
  -- Find source
  local modulePath = string.gsub(name, "%.", "/")
  for path in string.gmatch(package.path, "([^;]+)") do
    local fileName = string.gsub(path, "%?", modulePath)
    local file = io.open(fileName, "rb")
    if file then
      fileNames[name] = fileName
      return file:read("*a")
    end
    errors[#errors+1] = "\n\tno file '"..fileName.."' (attempted with lusty inline)"
  end
  return nil, table.concat(errors)
end

local function rewriteError(message, fileName)
  local ok, err = pcall(function()
    if type(message) == 'string' then
      local _, _, lineNumber = message:find(':(%d):')
      lineNumber = lineNumber - 2
      if lineNumber > 0 then
        if message:find('%[.*%]') then
          return message:gsub('%[.*%]', fileName):gsub(':%d:', ':'..lineNumber..':')
        end
      end
    end
    return message
  end)
  return err
end

--load file, memoize, execute loaded function inside environment
local function inline(name, env)
  local file = loaded[name]
  if not file then
    local fileName = nil
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
        'local _env=select(2, ...)\nlocal '..table.concat(keys, ',')..
        "=_env."..table.concat(keys, ",_env.")..
        '\n'..code
      )
    else
      file, err = loadstring(code)
    end
    if not file then error(rewriteError(err, fileNames[name])) end
    loaded[name] = file
  end
  local res = {xpcall(function() return file(name, env) end, function(m) return rewriteError(m, fileNames[name]) end)}
  if res[1] then
    return select(2, unpack(res))
  else
    error(res[2])
  end
end

local function clearCache()
  loaded = {}
end

return {
  inline = inline,
  clearCache = clearCache,
}
