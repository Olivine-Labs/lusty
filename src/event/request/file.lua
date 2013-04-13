return {
  handler = function(context)
    lusty.inline(config.file, {context=context})
  end
}
