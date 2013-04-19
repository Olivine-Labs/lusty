package.path = './spec/?.lua;../src/?.lua;'..package.path

function tableMerge(t1, t2)
    for k,v in pairs(t2) do
      if type(v) == "table" then
        if type(t1[k] or false) == "table" then
          tableMerge(t1[k] or {}, t2[k] or {})
        else
          t1[k] = v
        end
      else
        t1[k] = v
      end
    end

    return t1
end

describe("Lusty core test", function()
  local lusty = require 'lusty'

  local generateConfig = function(overrides)
    overrides = overrides or {}

    local config = tableMerge({
      subscribers = {
        request = {}
      },
      server = require 'dummy.server',
      publishers = {
        {"request"}
      },
      context={}
    }, overrides)

    return config
  end

  it("fires different pages", function()
    local config = generateConfig({
      subscribers = {
        request = {
          a = 'dummy.test-handler-a',
          b = 'dummy.test-handler-b'
        }
      }
    })

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
