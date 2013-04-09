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
  response.send = function(body)
    ngx.log(ngx.DEBUG, body)
    ngx.say(body)
    ngx.flush(true)
  end

  response = setmetatable(response, {
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
      elseif key =="body" then
        rawset(self, key, value)
      end
    end
  })

  response.headers = ngx.header

  return response
end

server.getRequest = getRequest
server.getResponse = getResponse

return server
