describe("Lusty core test", function()
  it("fires different pages", function()
    local lusty = require 'lusty.init'()
    lusty:subscribe({'request','a'}, 'spec.dummy.test-handler-a', {})
    lusty:subscribe({'request','b'}, 'spec.dummy.test-handler-b', {})
    table.insert(lusty.publishers, {'request'})

    local request = require 'spec.dummy.request'
    local response = require 'spec.dummy.response'
    request.url = "a"

    local context = { request = request, response = response }
    context.suffix = {'a'}
    lusty:request(context)
    if context.errors then error(context.errors) end
    assert.are.equal("a", context.output)

    request.url = "b"
    context.suffix = {'b'}
    lusty:request(context)
    if context.errors then error(context.errors) end
    assert.are.equal("b", context.output)
  end)
end)
