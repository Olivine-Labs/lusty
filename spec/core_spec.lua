package.path = './spec/?.lua;../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'

  it("fires different pages", function()
    local config = {
      context = {},
      server = require 'dummy.server',
      subscribers = {
        ['request:a'] = {
          'dummy.test-handler-a'
        },
        ['request:b'] = {
          ['dummy.test-handler-b'] = {}
        }
      },
      publishers = {
        {'request'}
      }
    }

    local lusty = lusty(config)

    local request = require 'dummy.request'
    request.url = "a"

    local context = lusty:request(request)
    assert.are.equal("a", context.output)

    request.url = "b"

    local context = lusty:request(request)
    assert.are.equal("b", context.output)
  end)
end)
