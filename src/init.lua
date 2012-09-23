return setmetatable({
  --Lusty
  event       = require 'mediator'(),
  publishers  = {},
  subscribers = {},
  options     = require 'say',
  server      = 'base', --base server stub, overridden by config
  path        = 'config',
  loaded      = {},

  log         = require 'log',

  --Run config file with lusty as context
  configure = function(self, file)
    if type(self) == "string" then
      file = self
      self = nil
    end
    if not self then self = getfenv(2) end
    local f = package.loaders[2](self.path..'/'..file)
    if type(f) == "string" then error(f, 2) end
    self.options:set_namespace(file)
    setfenv(f, self)()
    self.options:set_namespace('lusty')
  end,

  --Lazily load subscribers on publish
  publish = function(self, channel, context)
    --loads and registers a subscriber
    local subscribe = function(channel, list)
      for _,mod in pairs(list) do
        if type(mod) == "string" then
          local subscriber = require(mod)
          self.event:subscribe(channel, subscriber.handler, subscriber.options)
        end
      end
    end

    local list = self.subscribers
    local currentNamespace = {}
    --used to store a record of loaded namespaces
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
  end,

  --Publish events
  process = function(self, context)
    for _,channel in pairs(self.publishers) do
      self:publish(channel, context)
    end
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self.path = path or self.path

    self.options:set_fallback('lusty')
    self.options:set_namespace('lusty')

    self:configure('lusty')
    self:configure('subscribers')
    self:configure('publishers')

    self.server = require('server.'..self.server)

    local context = {
      lusty     = self,
      request   = self.server.request,
      response  = self.server.response,
      data      = {}
    }
    self:process(context)
    --sets say back to defaults, for other libraries that might use it.
    self.options:set_fallback('en')
    self.options:set_namespace('en')

    return context
  end
})
