--LUSTY
--An event based modular request router

--load file, memoize, execute loaded function with arguments
local function requireArgs(name, ...)
  local file = package.loaded[name]

  if not file then
    file = package.loaders[2](name)
    package.loaded[name] = file
  end

  return file(...)
end

--loads and registers a subscriber
local function subscribe(self, channel, subscriberName, config)
  local subscriber = requireArgs(subscriberName, self, config)

  local composedHandler = function(context)
    subscriber.handler(context)
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
    local newChannel = channel

    if type(k) == "number" and type(v) == "table" then
      for k2, v2 in pairs(v) do
        local name = ""
        local config = {}
        if type(k2) == "number" then
          name=v2
        else
          name=k2
          config=v2
        end
        subscribe(self, newChannel, name, config)
      end
    else
      if type(k) == "string" then
        newChannel = copy(channel)
        table.insert(newChannel, k)
      end

      local valueType = type(v)

      if valueType == "string" then
        subscribe(self, newChannel, v, false)
      elseif valueType == "table" then
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

local function publish(self, channel, context)
  table.insert(channel, context.request.headers.method)

  for _, v in pairs(split(context.request.url, '/')) do
    table.insert(channel, v)
  end

  self.event:publish(channel, context)
end

--Publish events
local function publishers(self, context)
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

  for k, v in pairs(contextConfig) do
    local path, config = "", {}

    if type(k) == "number" then
      path = v
    else
      path = k
      config = v
    end

    package.loaders[2]('context.'..path)(context, config)
  end

  return context
end

local function doRequest(self)
  local context = setmetatable({
    request   = self.config.server.getRequest(),
    response  = self.config.server.getResponse(),
    input     = {},
    output    = {},
  }, self.context.__meta)

  --Do events, publish with context
  publishers(self, context)

  --finally, return the context
  return context
end

local __meta = {

  --instantiate a lusty request handler
  __call = function(self, config)

    local lusty = {
      event             = require 'mediator'(),
      doRequest         = doRequest,
      requireArgs       = requireArgs
    }

    lusty.config = config
    lusty.context = globalContext(lusty, lusty.config.context)
    subscribers(lusty)

    return lusty
  end
}

return setmetatable({}, __meta)
