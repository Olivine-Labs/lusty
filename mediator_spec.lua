require "lunit"
Mediator, Channel, Subsciber = dofile("mediator.lua")

module("mediator_testcase", lunit.testcase, package.seeall)

local c, testfn, testfn2, testfn3

function setup()
  m = Mediator()
  c = Channel("test")
  testfn = function() end
  testfn2 = function() end
  testfn3 = function() end
end

function teardown()
  m = nil
  c = nil
  testfn = nil
  testfn2 = nil
  testfn3 = nil
end

function RegisterCallbacksTest()
  local sub1 = c:addSubscriber(testfn, {})

  assert(#c.callbacks == 1)
  assert(c.callbacks[1].fn == testfn)
end

function RegisterMoreCallbacksTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})

  assert(#c.callbacks == 2)
  assert(c.callbacks[2].fn == sub2.fn)
end

function RegisterCallbacksWithPriorityTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})
  local sub3 = c:addSubscriber(testfn3, { priority = 1 }, {})

  assert(c.callbacks[1].fn == sub3.fn)
end

function GetSubscriberTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})

  gotten = c:getSubscriber(sub1.id)

  assert(gotten.value == sub1)
end

function SetPriorityForwardTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})

  c:setPriority(sub2.id, 1)

  assert(c.callbacks[1] == sub2)
end

function SetPriorityBackwardsTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})

  c:setPriority(sub1.id, 2)

  assert(c.callbacks[2] == sub1)
end

function AddChannelTest()
  c:addChannel("level2")
  assert_not_nil(c.channels["level2"])
end

function HasChannelTest()
  c:addChannel("level2")
  assert(c:hasChannel("level2"))
end

function GetChannelTest()
  c:addChannel("level2")
  assert_not_nil(c:getChannel("level2"))
end

function RemoveSubscriberTest()
  local sub1 = c:addSubscriber(testfn, {})
  local sub2 = c:addSubscriber(testfn2, {})

  c:removeSubscriber(sub2.id)

  assert_nil(c:getSubscriber(sub2.id))
end

function GetSubscriberInInternalChannelTest()
  c:addChannel("level2")

  local sub1 = c.channels["level2"]:addSubscriber(testfn, {})

  gotten = c:getSubscriber(sub1.id)

  assert(gotten.value == sub1)
end

function RemoveSubscriberInInternalChannelTest()
  c:addChannel("level2")

  local sub1 = c.channels["level2"]:addSubscriber(testfn, {})

  c:removeSubscriber(sub1.id)

  assert_nil(c.channels["level2"]:getSubscriber(sub1.id))
end

function PublishTest()
  local olddata = { test = false }
  local data = { test = true }

  local assertFn = function(data)
    olddata = data
  end

  local sub1 = c:addSubscriber(assertFn, {})
  c:publish(data)

  assert(olddata.test)
end

function PublishMultipleArgumentsTest()
  local data = { test = true }
  local arguments

  local assertFn = function(data, wat, seven)
    arguments = { data = data, wat = wat, seven = seven }
  end

  local sub1 = c:addSubscriber(assertFn, {})
  c:publish("test", data, "wat", "seven")

  assert(#arguments)
end

function StopPublishTest()
  local olddata = { test = 0 }
  local data = { test = 1 }
  local data2 = { test = 2 }

  local assertFn = function(data)
    olddata = data
    c:stopPropagation()
  end

  local assertFn2 = function(data)
    olddata = data2
  end

  local sub1 = c:addSubscriber(assertFn, {})
  local sub2 = c:addSubscriber(assertFn2, {})
  c:publish(data)

  assert(olddata.test == 1)
end

function PublishRecursiveTest()
  local olddata = { test = false }
  local data = { test = true }

  local assertFn = function(...)
    olddata = data
  end

  c:addChannel("level2")

  local sub1 = c.channels["level2"]:addSubscriber(assertFn, {})

  c:publish(data)

  assert(olddata.test)
end

function GetChannelAtMediatorLevelTest()
  assert_not_nil(m:getChannel({"test", "level2"}))
  assert(m:getChannel({"test", "level2"}) == m:getChannel({"test"}):getChannel("level2"))
end

function PublishAtMediatorLevelTest()
  local assertFn = function(data, channel)
    olddata = data
    channel:stopPropagation()
  end

  local s = m:subscribe({"test"}, assertFn)

  assert_not_nil(m:getChannel({ "test" }):getSubscriber(s.id))
end

function GetSubscriberAtMediatorLevelTest()
  local assertFn = function(data, channel)
    olddata = data
    channel:stopPropagation()
  end

  local s = m:subscribe({"test"}, assertFn)

  assert_not_nil(m:getSubscriber(s.id, { "test" }))
end


function RemoveSubscriberAtMediatorLevelTest()
  local assertFn = function(data)
    olddata = data
  end

  local s = m:subscribe({"test"}, assertFn)

  assert_not_nil(m:getSubscriber(s.id, { "test" }))

  m:removeSubscriber(s.id, {"test"})

  assert_nil(m:getSubscriber(s.id, { "test" }))
end

function PublishSubscriberAtMediatorLevelTest()
  local olddata = "wat"

  local assertFn = function(data)
    olddata = data
  end

  local s = m:subscribe({"test"}, assertFn)
  m:publish({"test"}, "hi")

  assert(olddata == "hi")
end
