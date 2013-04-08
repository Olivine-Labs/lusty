local lusty, namespace = ...
lusty.config(namespace)
return {
  handler = function(context)
    local file = context.options('file')
    lusty:requireArgs(file, context)
 end
}
