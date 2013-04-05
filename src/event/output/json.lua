return {
  handler = function(context)
    context.response.headers["content-type"] = "application/json"
    local output = context.output
    local meta = getmetatable(output)
    if meta and type(meta.__toView) == "function" then
      output = meta.__toView(output, context)
    end
    local json = require 'dkjson'
    context.response.body = json.encode(output)
  end,
  options = {
    predicate = function(context)
      local accept = context.request.headers.accept
      local content = context.request.headers["content-type"]
      if type(context.output) == "table" then
        if accept then
          return accept == "application/json"
        elseif content then
          return content == "application/json"
        else
          return true
        end
      end
      return false
    end
  }
}
