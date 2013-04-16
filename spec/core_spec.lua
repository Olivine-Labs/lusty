package.path = '../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'
  local config = {
    server = require 'server.stub',
    subscribers = {
      input = {
        { ['event.input.json'] = { json = require 'dkjson' } }
      },
      request = {
        { ['event.request.file'] = { file = 'handlers.root' } }
      },
      output = {
        { ['event.output.json'] = { json = require 'dkjson' } }
      },
      log = {
        { 'event.log.console' }
      }
    },
    publishers = {
      {"input"},
      {"request"},
      {"output"}
    },
    context = {
      ['context.log'] = {},
      ['context.store'] = {}
    }
  }

  it("Tests instantiation", function()
    local lusty = lusty(config)
    local context = lusty:request()
    assert.are.equal(context.response.status, 200)
  end)
end)
