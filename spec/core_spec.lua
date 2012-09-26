package.path = '../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'
  local config = {
    options = {
      ["config.requests.root"] = {
        file = 'config.handlers.root'
      }
    },
    server = 'stub',
    subscribers = {
      input = {
        'event.input.json'
      },
      request = {
        {'event.request.file', 'config.requests.root'}
      },
      output = {
        'event.output.json'
      },
      log = {
        'event.log.console'
      }
    },
    publishers = {
      {"input"},
      {"prerequest"},
      {"request"},
      {"postrequest"},
      {"output"}
    },
    interfaces = {
      'options',
      'log'
    }
  }

  it("Tests instantiation", function()
    lusty(config)
    assert.are.equal(lusty.server.response.status, 200)
  end)
end)
