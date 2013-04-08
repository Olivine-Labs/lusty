local context = ...

context.options = function(key)
  return context.lusty.config[context.lusty.current_namespace][key]
end
