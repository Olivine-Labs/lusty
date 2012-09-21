return setmetatable({
  --Lusty
  event       = require 'mediator'(),
  publishers  = {},
  server      = require 'server.base', --base server stub, overridden by config
  path        = 'config',

  --Run config file with lusty as context
  configure = function(self, file)
    if not file then
      file = self
      self = getfenv(2)
    end
    local f,e = loadfile(self.path..'/'..file)
    if not f then error(e, 2) end
    setfenv(f, self)()
  end,

  --Publish events
  process = function(self, context)
    print(#self.publishers)
    self.event:publish(self.publishers, context)
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self.path = path or self.path
    self:configure()
    local context = {
      lusty     = self,
      request   = self.server.request,
      response  = self.server.response
    }
    self:process(context)
  end
})
