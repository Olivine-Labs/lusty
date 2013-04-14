local config = ...
return {
  handler = function(context)
    context.lusty.inline(config.file, {context})
  end
}
