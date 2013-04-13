package.path = '../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'
  local config = {
    server = require 'server.stub',
    subscribers = {
      input = { 'event.input.json' },
      request = {
        { ['event.request.file'] = { file = 'handlers.root' } }
      },
      output = { 'event.output.json' },
      log = { 'event.log.console' }
    },
    publishers = {
      {"input"},
      {"request"},
      {"output"}
    },
    context = {
      'log',
      'store'
    }
  }

  it("Tests instantiation", function()
    local lusty = lusty(config)
    local context = lusty:request()
    assert.are.equal(context.response.status, 200)
  end)
end)
