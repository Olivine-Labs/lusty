return setmetatable({
  --Lusty
  event             = require 'mediator'(),
  config            = require 'config',
  server            = {},
  loaded            = {},
  current_namespace = 'lusty',

  subscribe = function(self, channel, subscriberName, configName)
    local subscriber = package.loaders[2](subscriberName)(self, configName)
    local composedHandler = function(context)
      self.current_namespace = configName or table.concat(channel, '.')
      subscriber.handler(context)
      self.current_namespace = 'lusty'
    end
    self.event:subscribe(channel, composedHandler, subscriber.options)
  end,

  --publish with lazy load of subscribers
  publish = function(self, channel, context)
    --only loads subscribers for parent channels of channel
    local function lazyLoad(self, channel)
      --loads and registers a subscriber
      local function subscribe(channel, list)
        for key,mod in pairs(list) do
          if type(key) ~= "string" then
            local subscriberName, configName = false, false
            if type(mod) == "table" then
              subscriberName = mod[1]
              if #mod > 1 then configName = mod[2] end
            elseif type(mod) == "string" then
              subscriberName = mod
            end
            self:subscribe(channel, subscriberName, configName)
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
    if type(path) == "string" then
      self.config.path = path or self.config.path
    else
      self.config = setmetatable(path, getmetatable(self.config))
    end

    self.config('lusty')

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

    return context
  end
})
