local oo = require "loop.simple"

-- Subscriber class and functions --

Subscriber = oo.class({
  options = nil,
  fn = nil,
  context = nil,
  channel = nil,
})

function Subscriber:__init(fn, options, context)
  return oo.rawnew(self, {
    options = options,
    fn = fn,
    context = context,
    channel = nil,
    id = math.random(10000000000)
  })
end

function Subscriber:Update(options)
  if options then
    self.fn = options.fn or self.fn
    self.context = options.context or self.context
    self.options = options.options or self.options
  end
end

-- Channel class and functions --

Channel = oo.class({
  namespace = nil,
  stopped = false,
  callbacks = {},
  channels = {}
})

function Channel:__init(namespace)
  return oo.rawnew(self, {
    namespace = namespace
  })
end

function Channel:AddSubscriber(fn, options, context)
  local callback = Subscriber(fn, options, context)
  local priority = (#self.callbacks + 1)

  if options and options.priority then
    if options.priority >= 0 and options.priority < (#self.callbacks + 1) then
      priority = options.priority
    end
  end

  table.insert(self.callbacks, priority, callback)

  return callback
end

function Channel:GetSubscriber(id)
  for i,v in pairs(self.callbacks) do
    if v.id == id then return { index = i, value = v } end
  end
end

function Channel:SetPriority(id, priority)
  callback = self:GetSubscriber(id)

  if callback then
    table.remove(self.callbacks, callback.index)
    table.insert(self.callbacks, priority, callback.value)
  end
end

function Channel:AddChannel(namespace)
  if(self.namespace) then
    namespace = self.namespace..":"..namespace
  end

  self.channels[namespace] = Channel(namespace)
end

function Channel:HasChannel(namespace)
  if self.channels[namespace] then return true end
  return false
end

function Channel:StopPropagation()
  self.stopped = true
end
