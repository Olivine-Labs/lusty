--LUSTY
--An event based modular request router

local function requireArgs(self, name, ...)

  local file = package.loaded[name]
  if not file then
    file = package.loaders[2](name)
    package.loaded[name] = file
  end
  return file(...)
end

--loads and registers a subscriber
local function subscribe(self, channel, subscriberName, configName)

  local subscriber = requireArgs(self, subscriberName, self, configName)

  local composedHandler = function(context)
    self.current_namespace = configName or table.concat(channel, '.')
    subscriber.handler(context)
    self.current_namespace = 'lusty'
  end

  self.event:subscribe(channel, composedHandler, subscriber.options)
end

local function copy(thing)
  local new = {}
  for k, v in pairs(thing) do
    new[k] = v
  end
  return new
end

local function subscribers(self, list, channel)

  if not channel then channel = {} end

  for k,v in pairs(list or self.config.subscribers) do

    local root = false
    local newChannel = channel
    if type(k) == "number" then
      root = true
    else
      newChannel = copy(channel)
      table.insert(newChannel, k)
    end

    local valueType = type(v)
    if valueType == "string" then
      subscribe(self, newChannel, v, false)
    elseif valueType == "table" then
      if root then
        local subscriberName, configName = false, false

        subscriberName = v[1]
        if #v > 1 then configName = v[2] end

        subscribe(self, newChannel, subscriberName, configName)
      else
        subscribers(self, v, newChannel)
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

  table.insert(channel, context.request.headers.method)

  for _, v in pairs(split(context.request.url, '/')) do
    table.insert(channel, v)
  end

  self.event:publish(channel, context)
end

--Publish events
local function publishRequest(self, context)

  for _,channel in pairs(self.config.publishers) do
    publish(self, copy(channel), context)
  end

end

--Add data to context
local function globalContext(self, contextConfig)

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

  local context = setmetatable({
    request   = self.server.getRequest(),
    response  = self.server.getResponse(),
    input     = {},
    output    = {},
  }, self.context.__meta)

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
      doRequest         = doRequest,
      requireArgs       = requireArgs
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
    lusty.context = globalContext(lusty, lusty.config.context)

    subscribers(lusty)

    return lusty
  end

}

return setmetatable({}, __meta)
