local lusty, context = ...
context.publish = function(channel, context)
  lusty:publish(channel, context)
end
