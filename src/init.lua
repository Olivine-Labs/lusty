return setmetatable({
  --Lusty
  event       = require 'mediator'(),
  publishers  = {},
  subscribers = {},
  options     = require 'say',
  server      = require 'server.base', --base server stub, overridden by config
  path        = 'config',
  loaded      = {},

  --Run config file with lusty as context
  configure = function(self, file)
    if type(self) == "string" then
      file = self
      self = nil
    end
    if not self then self = getfenv(2) end
    file = file or 'init'
    local f = package.loaders[2](self.path..'/'..file)
    if type(f) == "string" then error(f, 2) end
    setfenv(f, self)()
  end,

  --Publish events, lazily load subscribers
  process = function(self, context)
    local subscribe = function(channel, list)
      for _,mod in pairs(list) do
        if type(mod) == "string" then
          local subscriber = require(mod)
          self.event:subscribe(channel, subscriber.handler, subscriber.options)
        end
      end
    end

    for _,channel in pairs(self.publishers) do
      local list = self.subscribers
      local currentNamespace = {}
      local loaded = self.loaded
      for _,namespace in pairs(channel) do
        list = list[namespace]
        if not list then break end
        table.insert(currentNamespace, namespace)
        if not loaded[namespace] then
          subscribe(currentNamespace, list)
          loaded[namespace] = {}
        end
        loaded = loaded[namespace]
      end
      self.event:publish(channel, context)
    end
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self.path = path or self.path

    self:configure('subscribers')
    self:configure('publishers')

    local context = {
      lusty     = self,
      request   = self.server.request,
      response  = self.server.response,
      data      = {}
    }
    self:process(context)
    return context
  end
})
