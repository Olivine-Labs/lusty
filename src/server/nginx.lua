local server = { }

local function getRequest()
  local request = require 'server.request'
  request.url = ngx.var.uri

  request = setmetatable(request, {
    -- lazy-load all of the ngx data requests so we only call out to ngx when we
    -- have to

    __index = function(self, key)
      if key == "headers" then
        headers = ngx.req.get_headers()
        self.headers = headers
        return headers
      elseif key == "body" then
        if not self.body_was_read then
          self.body_was_read = true
          ngx.req.read_body()
        end
        body = ngx.req.get_body_data()
        self.body = body
        return body
      elseif key == "file" then
        if not self.body_was_read then
          self.body_was_read = true
          ngx.req.read_body()
        end
        file = ngx.req.get_body_file()
        self.file = file
        return file
      elseif key == "query" then
        query = ngx.req.get_uri_args()
        self.query = query
        return query
      elseif key == "method" then
        method = ngx.req.get_method()
        self.method = method
        return method
      elseif key == "params" then
        params = ngx.req.get_post_args()
        self.params = params
        return params
      end
    end
  })

  return request
end

local function getResponse()
  local response = require 'server.response'

  response.send = function(body)
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
      elseif key == "body" then
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
