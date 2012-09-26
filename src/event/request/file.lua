local lusty, namespace = ...
lusty.config(namespace)
return {
  handler = function(context)
    local func = package.loaders[2](context.options('file'))
    if type(func) == 'function' then 
      func(context)
    else
      context.log('error loading config file for file handler namespace '..namespace, 'ERROR')
    end
  end
}
