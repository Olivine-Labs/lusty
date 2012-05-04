local oo = require "loop.simple"

Subscriber = oo.class({
  options = nil,
  fn = nil,
  context = nil,
  channel = nil
})

function Subscriber:__init(fn, options, context)
  return oo.rawnew(self, {
    options = options,
    fn = fn,
    context = context,
    channel = nil
  })
end

function Subscriber:Update(options)
  if options then
    self.fn = options.fn or self.fn
    self.context = options.context or self.context
    self.options = options.options or self.options
  end
end

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
end

function Channel:StopPropagation()
  self.stopped = true
end
