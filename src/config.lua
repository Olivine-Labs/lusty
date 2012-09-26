local config = function(self, file)
  if type(self) == "string" then
    file = self
    self = nil
  end

  if not self then self = getfenv(2) end
  if self.path then
    local f = package.loaders[2](self.path..'/'..file)
    if type(f) == "string" then error(f, 2) end
    self.options:set_namespace(file)
    setfenv(f, self)()
    self.options:set_namespace('lusty')
  end
end

return setmetatable({
  options     = require 'say',
  publishers  = {},
  subscribers = {},
  interfaces  = {},
  server      = 'stub',
  path        = 'config',
  config      = config
},
{
  --Run config file with self as context
  __call = config
})
