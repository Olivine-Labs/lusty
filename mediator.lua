local oo = require "loop.base"

-- Subscriber class and functions --

Subscriber = oo.class{}

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

Channel = oo.class({
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
    sub = v:getSubscriber(id)
    if sub then return sub end
  end
end

function Channel:setPriority(id, priority)
  callback = self:getSubscriber(id)

  if callback.value then
    table.remove(self.callbacks, callback.index)
    table.insert(self.callbacks, priority, callback.value)
  end
end

function Channel:addChannel(namespace)
  if(self.namespace) then
    namespace = self.namespace..":"..namespace
  end

  self.channels[namespace] = Channel(namespace)
end

function Channel:hasChannel(namespace)
  if self.channels[namespace] then return true end
  return false
end

function Channel:getChannel(namespace)
  return self.channels[namespace]
end

function Channel:removeSubscriber(id)
  callback = self:getSubscriber(id)

  if callback.value then
    for i,v in pairs(self.channels) do
      v:removeSubscriber(id)
    end

    table.remove(self.callbacks, callback.index)
  end
end

function Channel:__tostring()
  return self.namespace
end

function Channel:publish(data)
  for i,v in pairs(self.callbacks) do
    if self.stopped then return end

    v.fn(data, self)
  end

  for i,v in pairs(self.channels) do
    v:publish(data)
  end
end

function Channel:stopPropagation()
  self.stopped = true
end

-- Mediator class and functions --

Mediator = oo.class{}

function Mediator:__init(fn, options)
  return oo.rawnew(self, {
  })
end

function Mediator:getChannel()
end

function Mediator:subscribe()
end

function Mediator:getSubscriber()
end

function Mediator:remove()
end

function Mediator:publish()
end
