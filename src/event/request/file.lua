return {
  handler = function(context)
    package.loaders[2](context.options('file'))(context)
  end
}
