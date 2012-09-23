return {
  handler = function(context)
    context.response.headers["content-type"] = "application/json"
    local json = require 'dkjson'
    context.response.body = json.encode(context.data)
  end,
  options = {
    predicate = function(context)
      local accept = context.request.headers.accept
      local content = context.request.headers["content-type"]
      if type(context.data) == "table" then
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
