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

local function copy(thing)
  local new = {}
  for k, v in pairs(thing) do
    new[k] = v
  end
  return new
end

local function allSubscribers(self, list, channel)
  if not channel then channel = {} end
  for k,v in pairs(list or self.config.subscribers) do
    local root = false
    local newChannel = channel
    if type(k) == "number" then
      root = true
    else
      newChannel = copy(channel)
      table.insert(channel, k)
    end

    if not root and type(v) == "string" then
      subscribeUnboxed(self, newChannel, v, false)
    elseif type(v) == "table" then
      if root then
        local subscriberName, configName = false, false

        if type(v) == "table" then
          subscriberName = v[1]
          if #v > 1 then configName = v[2] end

        elseif type(v) == "string" then
          subscriberName = v
        end

        subscribeUnboxed(self, newChannel, subscriberName, configName)

      else
        allSubscribers(self, v, newChannel)
      end
    end

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

  if self.config.lazy then
    --Lazily load subscribers for affected channels, then publish event
    subscribers(self, channel)
  end

  table.insert(channel, context.request.headers.method)

  for _, v in pairs(split(context.request.url, '/')) do
    table.insert(channel, v)
  end

  self.event:publish(channel, context)
end

--Publish events
local function publishRequest(self, context)

  for _,channel in pairs(self.config.publishers) do
    publish(self, channel, context)
  end

end

--Add data to context
local function loadDefaultContext(self, contextConfig)

  local context = {

    lusty = self,

    --meta table to load from default context
    __meta = {

      __index = function(context, key)
        return rawget(context, key) or self.context[key]
      end

    }

  }

  for _, path in pairs(contextConfig) do

    package.loaders[2]('context.'..path)(context)

  end

  return context
end

local function doRequest(self)

  local context = setmetatable({}, self.context.__meta)

  context.request   = self.server.getRequest()
  context.response  = self.server.getResponse()
  context.input     = {}
  context.output    = {}

  --Do events, publish with context
  publishRequest(self, context)

  --finally, return the context
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
      doRequest         = doRequest
    }

    --argument can either be a path to a config base path, or a fully built config table
    if type(config) == "string" then
      lusty.config.path = config
    elseif type(config) == "table" then
      lusty.config = setmetatable(config, getmetatable(lusty.config))
    end

    --Initiate configuration
    lusty.config('lusty')

    --Load server bindings based on configuration
    lusty.server = require('server.'..lusty.config.server)

    --Create the global context variables
    lusty.context = loadDefaultContext(lusty, lusty.config.context)

    if not lusty.config.lazy then
      allSubscribers(lusty)
    end

    return lusty
  end

}

return setmetatable({}, __meta)
