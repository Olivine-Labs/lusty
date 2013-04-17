return {
  handler = function(context)
    context.response.headers["content-type"] = "text/html"

    local output = context.output
    local meta = getmetatable(output)

    if meta and type(meta.__toView) == "function" then
      output = meta.__toView(output, context)
    end

    context.response.send(output)
  end,

  options = {
    predicate = function(context)
      if config.default then
        return true
      end

      local accept = context.request.headers.accept or "text/html"
      local content = context.request.headers["content-type"]

      return (accept and (accept:find("text/html") or accept:find("*/*"))) or
             (content and content:find("text/html"))
    end
  }
}
