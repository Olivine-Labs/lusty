local function getRequest()
  local request = require 'server.request',
  request.headers = ngx.req.get_headers()
  ngx.req.read_body()
  request.body = ngx.req.get_body_data()
end

local function getResponse()
  local response = require 'server.response'
  response.headers = ngx.header
  response = setmetatable(server.response, {
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
end

local server =  {
  getRequest = getRequest,
  getResponse = getResponse
}

return server
