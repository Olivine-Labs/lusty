package.path = '../src/?.lua;'..package.path

describe("Lusty core test", function()
  local lusty = require 'init'

  it("Tests instantiation", function()
    lusty('config_stub')
  end)
end)
