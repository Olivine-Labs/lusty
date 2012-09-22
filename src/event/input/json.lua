return {
  handler = function(context)
    local json = require 'dkjson'
    context.data = json.decode(context.request.body)
  end,
  options = {
    predicate = function(context)
      print('derp')
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
