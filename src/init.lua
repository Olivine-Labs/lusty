local util = require 'lusty.util'

--LUSTY
--An event based modular request router
return function()

  local lusty = {
    event       = require 'mediator'(),
    publishers  = {}
  }

  --global context
  lusty.context = {
    lusty = lusty,
    run = {},
    --meta table to load from global context
    __meta = {
      __index = function(context, key)
        return rawget(context, key) or lusty.context[key]
      end
    }
  }

  --loads and registers a subscriber
  function lusty:subscribe(channel, name, config)
    local subscriber = util.inline(name, {channel = channel, config=config})
    self.event:subscribe(channel, subscriber.handler, subscriber.options)
  end

  --publish single event
  function lusty:publish(channel, context)
    --append url to channel
    if context.url then
      for k=1, #context.url do channel[#channel+1] = context.url[k] end
    end
    return self.event:publish(channel, context)
  end

  function lusty:addContext(name, config)
    self.context.run[#self.context.run+1] = util.inline(name, {
      context=self.context,
      config=config
    })
  end

  function lusty:request(request, response)

    local context = setmetatable({
      url       = {},
      request   = request,
      response  = response,
      input     = {},
      output    = {}
    }, self.context.__meta)

    --split url at /
    string.gsub(request.url, "([^/]+)", function(c) context.url[#context.url+1] = c end)

    --do request context events
    for i=1, #self.context.run do
      self.context.run[i](context)
    end

    local stackTrace = ""

    --do publishers
    local ok, err = xpcall(function()
      for k=1, #self.publishers do
        self:publish({unpack(self.publishers[k])}, context)
      end
    end, function(message) stackTrace = debug.traceback("", 2) return message end)

    --if error, rewrite request to error page
    if not ok then
      context.request.url = "/500/"
      context.err=err
      context.trace = stackTrace
      for k=1, #self.publishers do
        self:publish({unpack(self.publishers[k])}, context)
      end
    end

    --finally, return the context
    return context
  end

  return lusty
end
