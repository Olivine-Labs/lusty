local lusty, config = ...

return {
  handler = function(context)
    lusty.requireArgs(config.file, context)
  end
}
