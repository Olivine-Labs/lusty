local lusty, namespace = ...
lusty.config(namespace)
return {
  handler = function(context)
    local file = context.options('file')
    local func = package.loaded[file]
    if func then
      func(context)
    else
      func = package.loaders[2](file)
      if type(func) == 'function' then
        func(context)
        package.loaded[file] = func
      else
        context.log('error loading config file for file handler namespace '..namespace, 'ERROR')
      end
    end
  end
}
