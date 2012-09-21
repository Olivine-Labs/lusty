return setmetatable({
  --Lusty
  event       = require 'mediator'(),
  publishers  = {},
  server      = require 'server.base', --base server stub, overridden by config
  path        = 'config',

  --Run config file with lusty as context
  configure = function(self, file)
    if not file and type(self) == "string" then
      file = self
      self = getfenv(2)
    elseif not file then
      file = 'init.lua'
    end
    local f,e = loadfile(self.path..'/'..file)
    if not f then error(e, 2) end
    setfenv(f, self)()
  end,

  --Publish events
  process = function(self, context)
    for _,v in pairs(self.publishers) do
      local channel = {}
      table.insert(channel, v)
      self.event:publish(channel, context)
    end
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
