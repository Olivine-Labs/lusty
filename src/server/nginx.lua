local server =  {
  request = require 'server.request',
  response = require 'server.response'
}

server.request.headers = ngx.req.get_headers()
ngx.req.read_body()
server.request.body = ngx.req.get_body_data()

server.response.headers = ngx.header

server.response = setmetatable(server.response, {
  __index = function(self, key)
    if key == "status" then
      return ngx.status
    else
      return rawget(self, key)
    end
  end,
  __newindex = function(self, key, value)
    if key == "status" then
      ngx.status = value
    else
      rawset(self, key, value)
    end
  end
})

return server
