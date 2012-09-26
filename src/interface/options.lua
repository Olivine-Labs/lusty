local lusty, context = ...
context.options = function(key)
  return lusty.config.options(key)
end
