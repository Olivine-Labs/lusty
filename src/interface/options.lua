local lusty, context = ...
context.options = function(key, namespace)
  if not namespace then namespace = 'lusty' end
  lusty.config.options:set_namespace(namespace)
  local option = lusty.config:options(key, namespace)
  lusty.config.options:set_namespace('lusty')
  return option
end
