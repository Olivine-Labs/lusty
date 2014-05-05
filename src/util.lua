local loader, loaded = package.loaders[2], package.loaded

local inlineMeta = {
  __index = function(self, key)
    return rawget(self, key) or _G[key]
  end
}

--load file, memoize, execute loaded function inside environment
local function inline(name, env)
  local file = loaded[name]
  if not file then
    file = string.dump(loader(name))
    loaded[name] = file
  end
  file = loadstring(file)
  if type(file) == 'string' then
    error(file)
  end
  return setfenv(file, setmetatable(env, inlineMeta))(name)
end

return {
  inline = inline
}
