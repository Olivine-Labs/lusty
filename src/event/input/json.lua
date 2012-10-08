return {
  handler = function(context)
    local json = require 'dkjson'
    context.input = json.decode(context.request.body)
  end,
  options = {
    predicate = function(context)
      local content = context.request.headers["content-type"]
      if context.request.body then
        if content then
          return content == "application/json"
        else
          return true
        end
      end
      return false
    end
  }
}
