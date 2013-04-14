local loader, loaded = package.loaders[2], package.loaded

local function copyGlobals()
  local globals = {}
  for k, v in pairs(_G) do
    globals[k] = v
  end
  return globals
end

local inlineEnv = copyGlobals()

--load file, memoize, execute loaded function inside environment
local function inline(name, env)
  local file = loaded[name]

  if not file then
    file = loader(name)
    loaded[name] = file
  end

  if env then
    for k, v in pairs(env) do
      inlineEnv[k] = v
    end
  end
  return setfenv(file, inlineEnv)()
end

return {
  inline = inline
}
