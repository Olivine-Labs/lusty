local oo = require "loop.base"

-- Subscriber class and functions --

local Subscriber = oo.class{}

function Subscriber:__init(fn, options)
  return oo.rawnew(self, {
    options = options,
    fn = fn,
    channel = nil,
    id = math.random(10000000000) -- sounds reasonable, rite?
  })
end

function Subscriber:update(options)
  if options then
    self.fn = options.fn or self.fn
    self.options = options.options or self.options
  end
end

-- Channel class and functions --

local Channel = oo.class({
  stopped = false
})

function Channel:__init(namespace)
  return oo.rawnew(self, {
    namespace = namespace,
    callbacks = {},
    channels = {}
  })
end

function Channel:addSubscriber(fn, options)
  local callback = Subscriber(fn, options)
  local priority = (#self.callbacks + 1)

  if options and options.priority then
    if options.priority >= 0 and options.priority < (#self.callbacks + 1) then
      priority = options.priority
    end
  end

  table.insert(self.callbacks, priority, callback)

  return callback
end

function Channel:getSubscriber(id)
  for i,v in pairs(self.callbacks) do
    if v.id == id then return { index = i, value = v } end
  end

  for i,v in pairs(self.channels) do
    local sub = v:getSubscriber(id)
    if sub then return sub end
  end
end

function Channel:setPriority(id, priority)
  local callback = self:getSubscriber(id)

  if callback.value then
    table.remove(self.callbacks, callback.index)
    table.insert(self.callbacks, priority, callback.value)
  end
end

function Channel:addChannel(namespace)
  self.channels[namespace] = Channel(namespace)
  return self.channels[namespace]
end

function Channel:hasChannel(namespace)
  return self.channels[namespace] and true
end

function Channel:getChannel(namespace)
  return self.channels[namespace]
end

function Channel:removeSubscriber(id)
  local callback = self:getSubscriber(id)

  if callback.value then
    for i,v in pairs(self.channels) do
      v:removeSubscriber(id)
    end

    table.remove(self.callbacks, callback.index)
  end
end

--function Channel:__tostring()
--  return self.namespace
--end

function Channel:publish(namespace, ...)
  for i,v in pairs(self.callbacks) do
    if self.stopped then return end

    table.insert(arg, 1, self)
    v.fn(unpack(arg))
  end

  for i,v in pairs(self.channels) do
    v:publish(namespace, unpack(arg))
  end
end

function Channel:stopPropagation()
  self.stopped = true
end

-- Mediator class and functions --

local Mediator = oo.class{}

function Mediator:__init(fn, options)
  return oo.rawnew(self, {
    channel = Channel('root')
  })
end

function Mediator:getChannel(channelNamespace)
  local channel = self.channel

  for i,v in pairs(channelNamespace) do
    if not channel:hasChannel(v) then
      channel = channel:addChannel(v)
    else
      channel = channel:getChannel(v)
    end
  end

  return channel;
end

function Mediator:subscribe(channelNamespace, fn, options)
  return self:getChannel(channelNamespace):addSubscriber(fn, options)
end

function Mediator:getSubscriber(id, channelNamespace)
  return self:getChannel(channelNamespace):getSubscriber(id)
end

function Mediator:removeSubscriber(id, channelNamespace)
  return self:getChannel(channelNamespace):removeSubscriber(id)
end

function Mediator:publish(channelNamespace, ...)
  self:getChannel(channelNamespace).publish(...)
end

return Mediator, Channel, Subscriber
