return {
  handler = function(context)
    context.store("logs", {
      level=context.level,
      message = context.message
    })
  end
}
