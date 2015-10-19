local util = require 'lusty.util'
count = count + 1
if count == 5 then
util.inline('spec.dummy.error', {test=test, foo=foo, count=count})
else
util.inline('spec.dummy.multilevel', {test=test, foo=foo, count=count})
end
