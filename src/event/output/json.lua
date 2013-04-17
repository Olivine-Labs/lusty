local json = config.json

return {
  handler = function(context)
    context.response.headers["content-type"] = "application/json"

    local output = context.output
    local meta = getmetatable(output)

    if meta and type(meta.__toView) == "function" then
      output = meta.__toView(output, context)
    end

    context.response.send(json.encode(output))
  end,

  options = {
    predicate = function(context)
      if config.default then
        return true
      end

      local accept = context.request.headers.accept
      local content = context.request.headers["content-type"]

      return (accept and accept:find("application/json")) or
             (content and content:find("application/json"))
    end
  }
}
