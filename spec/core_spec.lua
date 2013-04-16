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
  local lusty = require 'init'

  local generateConfig = function(overrides)
    overrides = overrides or {}

    local config = tableMerge({
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
    }, overrides)

    return config
  end

    it("Tests instantiation", function()
    local config = generateConfig()
    local lusty = lusty(config)
    local context = lusty:request()
    assert.are.equal(context.response.status, 200)
  end)

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

    local request = require 'server.request'
    request.url = "a"

    local context = lusty:request(request)
    assert.are.equal(context.output, "a")

    request.url = "b"

    local context = lusty:request(request)
    assert.are.equal(context.output, "b")
  end)
end)
