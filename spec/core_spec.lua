package.path = './spec/?.lua;../src/?.lua;'..package.path

describe("Lusty core test", function()
  it("fires different pages", function()
    local lusty = require 'init'()
    lusty:subscribe({'request','a'}, 'dummy.test-handler-a', {})
    lusty:subscribe({'request','b'}, 'dummy.test-handler-b', {})
    table.insert(lusty.publishers, {'request'})

    local request = require 'dummy.request'
    local response = require 'dummy.response'
    request.url = "a"

    local context = lusty:request(request, response)
    assert.are.equal("a", context.output)

    request.url = "b"

    local context = lusty:request(request, response)
    assert.are.equal("b", context.output)
  end)
end)
