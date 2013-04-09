return {
  handler = function(context)
    if not context.output["error"] then
      context.output["error"] = {}
    end

    table.insert(context.context.error, {
      level = context.level, 
      message = context.message
    })
  end
}
