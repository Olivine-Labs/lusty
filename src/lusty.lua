--LUSTY
--An event based modular request router
local util = require 'lusty.util'

--loads and registers a subscriber
local function subscribe(self, channel, name, config)
  local subscriber = util.inline(name, {config=config})
  self.event:subscribe(channel, subscriber.handler, subscriber.options)
end

local function subscribers(self)
  for serializedChannel, list in pairs(self.config.subscribers) do
    local channel = {}
    string.gsub(serializedChannel, "([^:]+)", function(c) channel[#channel+1] = c end)
    for subscriber, config in pairs(list) do
      if type(subscriber) == "number" then
        subscriber = config
        config = {}
      end
      subscribe(self, channel, subscriber, config)
    end
  end
end

local function publish(self, channel, context, urlTable)
  for k=1, #urlTable do
    channel[#channel+1] = urlTable[k]
  end

  self.event:publish(channel, context)
end

--Publish events
local function publishers(self, context)
  local urlTable, publishers = {}, self.config.publishers

  --split url at /
  string.gsub(context.request.url, "([^/]+)", function(c) urlTable[#urlTable+1] = c end)

  for k=1, #publishers do
    publish(self, {unpack(publishers[k])}, context, urlTable)
  end
end

--Add data to context
local function context(self)

  local ctxt = {
    run = {},
    --meta table to load from default context
    __meta = {
      __index = function(context, key)
        return rawget(context, key) or self.context[key]
      end
    }
  }

  for k, v in pairs(self.config.context) do
    local path, config

    if type(k) == "number" then
      path = v
      config = {}
    else
      path = k
      config = v
    end

    local result = util.inline(path, {context=ctxt, config=config})
    if result then
      ctxt.run[#ctxt.run+1] = result
    end
  end

  ctxt.lusty = self

  self.context = ctxt
end

local function request(self, request)
  local server = self.config.server

  local context = setmetatable({
    request   = request or server.getRequest(),
    response  = server.getResponse(),
    input     = {},
    output    = {}
  }, self.context.__meta)

  --do request context events
  for i=1, #self.context.run do
    self.context.run[i](context)
  end

  --Do events, publish with context
  publishers(self, context)

  --finally, return the context
  return context
end

--instantiate a lusty request handler
local function init(config)

  local lusty = {
    config            = config,
    event             = require 'mediator'(),
    request           = request,
  }

  context(lusty)

  subscribers(lusty)

  return lusty
end

return init
