local lusty, context = ...
context.options = function(key)
  return lusty.config.options[lusty.current_namespace][key]
end
