return setmetatable({
  --Lusty
  event   = require 'mediator'(),
  publishers = {},
  server  = require 'lusty.server.base', --base server stub, overridden by config
  --Run config file with lusty as context
  doConfig = function(self, file)
    if not self then self = getfenv() end
    local f,e = loadfile(file)
    if not f then error(e, 2) end
    setfenv(f, self)()
  end,
  --execute initial config file
  configure = function(self, path)
    self:doConfig(path.."/init.lua")
  end,
  --Publish events
  process = function(self, context)
    for _,v in pairs(self.publishers) do
      self.event:publish(v, context)
    end
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self:configure(path or 'config'),
    local context = {
      lusty = self,
      request = self.server.request,
      response = self.server.response
    }
    self:process(context)
  end
})
