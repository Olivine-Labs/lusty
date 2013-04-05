--LUSTY
--An event based modular request router

--loads and registers a subscriber
local function subscribeUnboxed(self, channel, subscriberName, configName)

  local subscriber = package.loaders[2](subscriberName)(self, configName)

  local composedHandler = function(context)
    self.current_namespace = configName or table.concat(channel, '.')
    subscriber.handler(context)
    self.current_namespace = 'lusty'
  end

  self.event:subscribe(channel, composedHandler, subscriber.options)
end

local function subscribe(self, channel, list)

  for key,mod in pairs(list) do

    if type(key) ~= "string" then

      local subscriberName, configName = false, false

      if type(mod) == "table" then
        subscriberName = mod[1]
        if #mod > 1 then configName = mod[2] end

      elseif type(mod) == "string" then
        subscriberName = mod
      end

      subscribeUnboxed(self, channel, subscriberName, configName)

    end
  end

end

--only loads subscribers for parent channels of channel
local function subscribers(self, channel)

  local list = self.config.subscribers
  local currentNamespace = {}

  --used to store a record of loaded namespaces
  local loaded = self.loaded

  for _, namespace in pairs(channel) do

    list = list[namespace]
    if not list then break end

    table.insert(currentNamespace, namespace)

    if not loaded[namespace] then
      subscribe(self, currentNamespace, list)
      loaded[namespace] = {}
    end

    loaded = loaded[namespace]
  end

end

local function split(str, sep)

  local sep, fields = sep or ":", {}

  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)

  return fields

end

--publish with lazy load of subscribers
local function publish(self, channel, context)

  --Lazily load subscribers for affected channels, then publish event
  subscribers(self, channel)

  table.insert(channel, context.request.headers.method)

  for _, v in pairs(split(context.request.url, '/')) do
    table.insert(channel, v)
  end

  self.event:publish(channel, context)
end

--Publish events
local function publishers(self, context)
  for _,channel in pairs(self.config.publishers) do
    publish(self, channel, context)
  end
end

--Add data to context
local function makeContext(self)

  local context = {
    lusty = self
  }

  for _, path in pairs(self.config.context) do
    package.loaders[2]('context.'..path)(self, context)
  end

  return context

end

local __meta = {

  --instantiate a lusty request handler
  __call = function(self, config)

    local lusty = {
      event             = require 'mediator'(),
      config            = require 'config',
      server            = {},
      loaded            = {},
      current_namespace = 'lusty',
    }

    --argument can either be a path to a config base path, or a fully built config table
    if type(config) == "string" then
      lusty.config.path = config
    else
      lusty.config = setmetatable(config, getmetatable(lusty.config))
    end

    --Initiate configuration
    lusty.config('lusty')

    --Load server bindings based on configuration
    lusty.server = require('server.'..lusty.config.server)

    --Create the context
    local context = makeContext(lusty)

    --Do events, publish with context
    publishers(lusty, context)

    --and finally return the context so the results of the request may be examined
    return context

  end

}

return setmetatable({}, __meta)
