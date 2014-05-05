local loaded = package.loaded

--load file, memoize, execute loaded function inside environment
local function inline(name, channel, config, context)
  local file = loaded[name]
  if not file then
      local err
      for _, v in pairs(package.loaders) do
        file, err = v(name)
        if type(file) == "function" then break end
      end
      if file == nil then
        error(err)
      end
      if type(file) ~= "function" then
        error(file)
      end

    loaded[name] = file
  end

  return file(name, channel, config, context)
end

return {
  inline = inline
}
