--LUSTY
--An event based modular request router
local util = require 'lusty.util'

--loads and registers a subscriber
local function subscribe(self, channel, name, config)
  local subscriber = util.inline(name, {config=config})
  self.event:subscribe(channel, subscriber.handler, subscriber.options)
end

local function subscribers(self, list, channel)
  if not channel then channel = {} end

  for k, v in pairs(list or self.config.subscribers) do
    local newChannel = channel
    local vt, kt = type(v), type(k)

    if kt == "number" and vt == "table" then
      for k2, v2 in pairs(v) do
        local name, config
        if type(k2) == "number" then
          name=v2
        else
          name=k2
          config=v2
        end
        subscribe(self, newChannel, name, config)
      end
    else
      if kt == "string" then
        newChannel = {unpack(channel)}
        newChannel[#newChannel+1]=k
      end

      if vt == "string" then
        subscribe(self, newChannel, v)
      elseif vt == "table" then
        subscribers(self, v, newChannel)
      end
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
local function context(self, contextConfig)

  local ctxt = {
    run = {},
    --meta table to load from default context
    __meta = {
      __index = function(context, key)
        return rawget(context, key) or self.context[key]
      end
    }
  }

  for k, v in pairs(contextConfig) do
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

  return ctxt
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

  lusty.context = context(lusty, config.context)
  subscribers(lusty)

  return lusty
end

return init
