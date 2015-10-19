local loaded = {}
local chunks = {}
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

local function rewriteLineNumber(message, lineMod)
  if type(message) == 'string' then
    if lineMod ~= 0 then
      local _, _, lineNumber = message:find(':(%d):')
      if tonumber(lineNumber) and tonumber(lineNumber) > 0 then
        message = message:gsub(':'..lineNumber..':', ':'..(lineNumber+lineMod)..':')
      end
    end
  end
  return message
end

--load file, memoize, execute loaded function inside environment
local function inline(name, env)
  local keys, values = {}, {}
  local n = 1
  for k, v in pairs(env) do
    keys[n] = k
    values[n] = v
    n = n + 1
  end
  local lineMod = 0
  if n > 1 then
    lineMod = -1
  end

  local namespace = loaded[name]
  local file, signature = nil, table.concat(keys, '/')
  if namespace then
    file = namespace[signature]
  end
  if not file then
    local fileName = nil
    local code = chunks[name]
    local err
    if not code then
      code, err = loadModule(name)
      if not code then
        error(err)
      end
      chunks[name] = code
    end
    if #keys > 0 then
      file, err = loadstring(
        'local '..table.concat(keys, ',')..'=select(2, ...)\n'..code,
        fileNames[name]
      )
    else
      file, err = loadstring(code, fileNames[name])
    end
    if not file then error(rewriteLineNumber(err, lineMod)) end
    if not namespace then
      namespace = {}
      loaded[name] = namespace
    end
    loaded[name][signature] = file
  end

  local res = {
    xpcall(function()
      return file(name, unpack(values, 1, n))
    end, function(m)
      return rewriteLineNumber(m, lineMod)
    end)
  }

  if res[1] then
    return unpack(res, 2, table.maxn(res))
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
