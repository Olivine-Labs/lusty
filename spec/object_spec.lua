package.path = '../src/?.lua;../lib/?.lua;'..package.path
local Object = require 'object'

require 'lunit'
module('lusty.test.lua.object', lunit.testcase, package.seeall)
function test_inheritance()
  local Child = Object:extend()
  local GrandChild = Child:extend()

  local object = Object()
  local child = Child()
  local grandchild = GrandChild()

  assert_true(object:instanceof(Object), 'Object is not an instance of Object')
  assert_true(child:instanceof(Object), 'Child is not an instance of Object')
  assert_true(grandchild:instanceof(Object), 'GrandChild is not an instance of Object')
  assert_true(grandchild:instanceof(Child), 'GrandChild is not an instance of Child')
  assert_false(object:instanceof(Child), 'Object is an instance of Child')
  assert_false(object:instanceof(GrandChild), 'Object is an instance of GrandChild')
  assert_false(child:instanceof(GrandChild), 'Child is an instance of GrandChild')
end
