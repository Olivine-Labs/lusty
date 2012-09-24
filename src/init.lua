return setmetatable({
  --Lusty
  event       = require 'mediator'(),
  config      = require 'config',
  server      = {},
  loaded      = {},

  --publish with lazy load of subscribers
  publish = function(self, channel, context)
    --only loads subscribers for parent channels of channel
    local function lazyLoad(self, channel)
      --loads and registers a subscriber
      local function subscribe(channel, list)
        for _,mod in pairs(list) do
          if type(mod) == "string" then
            local subscriber = require(mod)
            self.event:subscribe(channel, subscriber.handler, subscriber.options)
          end
        end
      end

      local list = self.config.subscribers
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
    end
    --Lazily load subscribers for affected channels, then publish event
    lazyLoad(self, channel)
    self.event:publish(channel, context)
  end,

  --Publish events
  processPublishers = function(self, context)
    for _,channel in pairs(self.config.publishers) do
      self:publish(channel, context)
    end
  end,
  --Add interfaces to context
  processInterfaces = function(self, context)
    for _,v in pairs(self.config.interfaces) do
      package.loaders[2]('interface.'..v)(self, context)
    end
  end
},
{
  --Lusty Meta-Table
  __call = function(self, path)
    self.config.path = path or self.config.path

    self.config.options:set_fallback('lusty')
    self.config.options:set_namespace('lusty')

    self.config('lusty')
    self.config('subscribers')
    self.config('publishers')
    self.config('interfaces')

    self.server = require('server.'..self.config.server)

    local context = {
      request   = self.server.request,
      response  = self.server.response,
      --data work table.
      --Used to manipulate response data before output
      data      = {}
    }

    --load interfaces, they set themselves up on context
    self:processInterfaces(context)

    --Do events, publish with context
    self:processPublishers(context)

    --sets say back to defaults, for other libraries that might use it.
    self.config.options:set_fallback('en')
    self.config.options:set_namespace('en')

    return context
  end
})
