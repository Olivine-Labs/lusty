package.path = 'src/?.lua;'..package.path

describe('verify that inline handles environments properly', function()
  local util = require 'util'

  after_each(function()
    util.clearCache()
  end)

  it('can set an environment', function()
    local env = {foo='bar'}
    assert('bar' == util.inline('spec.dummy.inlineFunction', env))
  end)

  it('can set an environment with multiple variables', function()
    local env = {foo='bar', bat='baz'}
    assert.same({'bar','baz'}, {util.inline('spec.dummy.inlineFunction', env)})
  end)

  it('can set an environment with no variables', function()
    local env = {}
    assert.equal(nil, util.inline('spec.dummy.inlineFunction', env))
  end)
end)
