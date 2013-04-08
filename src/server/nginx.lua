local server = {
  response = {}
}

local function getRequest()
  local request = require 'server.request'
  request.headers = ngx.req.get_headers()
  ngx.req.read_body()
  request.body = ngx.req.get_body_data()

  return request
end

local function getResponse()
  local response = require 'server.response'

  response = setmetatable(response, {
    __index = function(self, key)
      if key == "status" then
        return ngx.status
      elseif key == "body" then
        return ngx.body
      else
        return rawget(self, key)
      end
    end,

    __newindex = function(self, key, value)
      if key == "status" then
        ngx.status = value
      elseif key =="body" then
        rawset(self, key, value)
      end
    end
  })

  for k,v in pairs(response.headers) do
    ngx.header[k] = v
  end

  ngx.say(response.body)
  ngx.flush(true)

  return response
end

server.getRequest = getRequest
server.getResponse = getResponse

return server
