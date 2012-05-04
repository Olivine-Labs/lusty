dofile("mediator.lua")

function test()
end

function test2()
end

s = Subscriber(test, { stuff = false }, {})
if(s.options.stuff == false) then print "1: ✔" else print "1: x" end

s:Update({ options = { stuff = true }})
if(s.options.stuff == true) then print "2: ✔" else print "2: x" end

c = Channel("test")
if(c.namespace == "test") then print "3: ✔" else print "3: x" end

sub1 = c:AddSubscriber(test, {}, {})
if(c.callbacks[1] ~= nil) then print "4: ✔" else print "4: x" end
if(c.callbacks[1].fn == test) then print "5: ✔" else print "5: x" end

sub2 = c:AddSubscriber(test2, {}, {})
if(c.callbacks[2].fn == test2) then print "6: ✔" else print "6: x" end

sub3 = c:AddSubscriber(test2, { priority = 1 }, {})
if(c.callbacks[1].fn == test2 and c.callbacks[2].fn == test) then print "7: ✔" else print "7: x" end

c:StopPropagation()
if(c.stopped) then print "8: ✔" else print "8: x" end

if (c:GetSubscriber(sub3.id).value.id == sub3.id) then print "9: ✔" else print "9: x" end 

c:SetPriority(sub2.id, 1)
if (c.callbacks[1].id == sub2.id) then print "10: ✔" else print "10: x" end 
