dofile("mediator.lua")

function test()
end

s = Subscriber(test, { stuff = false }, {})
if(s.options.stuff == false) then print "1: ✔" else print "1: x" end

s:Update({ options = { stuff = true }})
if(s.options.stuff == true) then print "2: ✔" else print "2: x" end

c = Channel("test")
if(c.namespace == "test") then print "3: ✔" else print "3: x" end

c:AddSubscriber(test, {}, {})
if(c.callbacks[1] ~= nil) then print "4: ✔" else print "4: x" end
if(c.callbacks[1].fn == test) then print "5: ✔" else print "5: x" end
