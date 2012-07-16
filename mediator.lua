-- Subscriber class and functions --

function Subscriber(fn, options)
  return {
    options = options,
    fn = fn,
    channel = nil,
    id = math.random(10000000000), -- sounds reasonable, rite?
    update = function(self,options)
      if options then
        self.fn = options.fn or self.fn
        self.options = options.options or self.options
      end
    end
  }
end

-- Channel class and functions --

function Channel(namespace)
  return {
    stopped = false,
    namespace = namespace,
    callbacks = {},
    channels = {},
    addSubscriber = function(self,fn, options)
      local callback = Subscriber(fn, options)
      local priority = (#self.callbacks + 1)

      if options and options.priority then
        if options.priority >= 0 and options.priority < (#self.callbacks + 1) then
          priority = options.priority
        end
      end

      table.insert(self.callbacks, priority, callback)

      return callback
    end,

    getSubscriber = function(self,id)
      for i,v in pairs(self.callbacks) do
        if v.id == id then return { index = i, value = v } end
      end

      for i,v in pairs(self.channels) do
        local sub = v:getSubscriber(id)
        if sub then return sub end
      end
    end,

    setPriority = function(self,id, priority)
      local callback = self:getSubscriber(id)

      if callback.value then
        table.remove(self.callbacks, callback.index)
        table.insert(self.callbacks, priority, callback.value)
      end
    end,

    addChannel = function(self,namespace)
      self.channels[namespace] = Channel(namespace)
      return self.channels[namespace]
    end,

    hasChannel = function(self,namespace)
      return self.channels[namespace] and true
    end,

    getChannel = function(self,namespace)
      return self.channels[namespace]
    end,

    removeSubscriber = function(self,id)
      local callback = self:getSubscriber(id)

      if callback.value then
        for i,v in pairs(self.channels) do
          v:removeSubscriber(id)
        end

        table.remove(self.callbacks, callback.index)
      end
    end,

    publish = function(self,channelNamespace, ...)
      for i,v in pairs(self.callbacks) do
        if self.stopped then return end

        v.fn(unpack(arg))
      end

      if #channelNamespace > 0 then
        local nextNamespace = channelNamespace[1]
        table.remove(channelNamespace, 1)
        self.channels[nextNamespace]:publish(channelNamespace, unpack(arg))
      else
        for i,v in pairs(self.channels) do
          v:publish({}, unpack(arg))
        end
      end
    end,

    stopPropagation = function(self)
      self.stopped = true
    end
  }
end

-- Mediator class and functions --

local Mediator = {}

function Mediator(fn, options)
  return {
    channel = Channel('root'),

    getChannel = function(self,channelNamespace)
      local channel = self.channel

      for i,v in pairs(channelNamespace) do
        if not channel:hasChannel(v) then
          channel = channel:addChannel(v)
        else
          channel = channel:getChannel(v)
        end
      end

      return channel;
    end,

    subscribe = function(self,channelNamespace, fn, options)
      return self:getChannel(channelNamespace):addSubscriber(fn, options)
    end,

    getSubscriber = function(self,id, channelNamespace)
      return self:getChannel(channelNamespace):getSubscriber(id)
    end,

    removeSubscriber = function(self,id, channelNamespace)
      return self:getChannel(channelNamespace):removeSubscriber(id)
    end,

    publish = function(self,channelNamespace, ...)
      self.channel:publish(channelNamespace, unpack(arg))
    end
  }
end

return Mediator, Channel, Subscriber
