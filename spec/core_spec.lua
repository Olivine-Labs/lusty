package.path = '../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'
  local config = {
    ["config.requests.root"] = {
      file = 'config.handlers.root'
    },
    log = {
      level = "debug"
    },
    lazy = false,
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
    context = {
      'options',
      'log',
      'store'
    }
  }

  it("Tests instantiation", function()
    local lusty = lusty(config)
    local context = lusty:doRequest()
    assert.are.equal(context.response.status, 200)
  end)
end)
