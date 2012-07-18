package.path = './?.lua;../lib/?.lua;'..package.path

local Lusty = {
  Object = require('object'),
  event = require('mediator.mediator')(),
  server = require('server.base'), --base server stub, overridden by config
  request = function(path, headers, body)
    --TODO:: creates and processes a new request context
  end
}

return setmetatable(Lusty,
{
  __call = function()
    --TODO:: includes config files which set up event handlers
    --and fires initial request event
    self.request(
      self.server.request.path,
      self.server.request.headers,
      self.server.request.body
    )
  end
})
