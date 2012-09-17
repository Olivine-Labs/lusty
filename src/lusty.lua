return setmetatable({
  --Lusty
  event   = require 'mediator'(),
  server  = require 'lusty.server.base', --base server stub, overridden by config
  configure = function(self, path)
    --TODO : include all lua files in path
  end,
  process = function(self, context)
    self.event:publish('input',       context)
    self.event:publish('prerequest',  context)
    self.event:publish('request',     context)
    self.event:publish('postrequest', context)
    self.event:publish('output',      context)
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self.configure(path or 'config'),
    local context = {
      lusty = self,
      request = self.server.request,
      response = self.server.response
    }
    self:process(context)
  end
})
