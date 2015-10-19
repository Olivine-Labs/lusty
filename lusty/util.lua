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
      if tonumber(lineNumber) and tonumber(lineNumber) > 0 then
        lineNumber = lineNumber - 1
        if message:find('%[string .*%]') then
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
  local keys ={}
  local values = {}
  for k, v in pairs(env) do
    keys[#keys+1] = k
    values[#values+1] = v
  end
  local file = loaded[name]
  if not file then
    local fileName = nil
    local code, err = loadModule(name)
    if not code then
      error(err)
    end
    if #keys > 0 then
      file, err = loadstring(
        'local '..table.concat(keys, ',')..'=select(2, ...)\n'..code
      )
    else
      file, err = loadstring(code)
    end
    if not file then error(rewriteError(err, fileNames[name])) end
    loaded[name] = file
  end
  local res = {xpcall(function() return file(name, unpack(values)) end, function(m) return rewriteError(m, fileNames[name]) end)}
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
