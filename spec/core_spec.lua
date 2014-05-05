package.path = './spec/?.lua;../src/?.lua;'..package.path

describe("Lusty core test", function()
  it("fires different pages", function()
    local lusty = require 'init'()
    lusty:subscribe({'request','a'}, 'dummy.test-handler-a', {})
    lusty:subscribe({'request','b'}, 'dummy.test-handler-b', {})
    table.insert(lusty.publishers, {'request'})

    local request = require 'dummy.request'
    local response = require 'dummy.response'

    local context = lusty:request({request = request, suffix = {'a'}, response = response})
    assert.are.equal("a", context.output)


    local context = lusty:request({request = request, suffix = {'b'}, response = response})
    assert.are.equal("b", context.output)
  end)
end)
