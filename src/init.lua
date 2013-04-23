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
    local subscriber = util.inline(name, {config=config})
    self.event:subscribe(channel, subscriber.handler, subscriber.options)
  end

 --publish single event
  function lusty:publish(channel, context)
    --append url to channel
    for k=1, #context.url do channel[#channel+1] = context.url[k] end
    self.event:publish(channel, context)
  end

  function lusty:addContext(name, config)
      self.context.run[#self.context.run+1] = util.inline(name, {
        context=context,
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

    --do publishers
    for k=1, #self.publishers do
      self:publish({unpack(self.publishers[k])}, context)
    end

    --finally, return the context
    return context
  end

  return lusty
end
