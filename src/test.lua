local lib = require 'init'
local config = {
  server = require 'server.stub',
  subscribers = {
    input = {
      { ['event.input.json'] = { json = require 'cjson' } }
    },
    request = {
      { ['event.request.file'] = { file = 'handlers.root' } }
    },
    output = {
      { ['event.output.json'] = { json = require 'cjson' } }
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
    'log',
    'store'
  }
}



local lusty = lib(config)

local startTime = os.clock()
local iteration = 1000000
for i = 1,iteration,1 do
  lusty:request()
end
local totalTime = os.clock() - startTime

print((iteration / totalTime).." requests per second")
