local name, channel, config = ...

return {
  handler = function(context)
    context.output = "a"
  end
}

