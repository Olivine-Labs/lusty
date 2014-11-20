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
    --append suffix to channel if exists
    if context.suffix then
      for k=1, #context.suffix do channel[#channel+1] = context.suffix[k] end
    end
    return self.event:publish(channel, context)
  end

  function lusty:addContext(name, config)
    self.context.run[#self.context.run+1] = util.inline(name, {
      context=self.context,
      config=config
    })
  end

  function lusty:request(context)

    --do request context events
    for i=1, #self.context.run do
      self.context.run[i](context)
    end

    --do publishers, handle errors
    for k=1, #self.publishers do

      xpcall(function()
        --quick copy publishers using unpack
        self:publish({unpack(self.publishers[k])}, context)
      end,
      --error handler
      function(message)

        if not context.error then context.error = {} end

        context.error[#context.error + 1] = {
          trace = debug.traceback("", 2),
          message = message
        }

      end)

    end

    --finally, return the context
    return context
  end

  return lusty
end
