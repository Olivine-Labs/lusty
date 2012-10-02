local lusty, context = ...
context.options = function(key)
  return lusty.config[lusty.current_namespace][key]
end
