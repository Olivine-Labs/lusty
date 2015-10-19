describe('verify that inline handles environments properly', function()
  local util = require 'lusty.util'

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
    assert.same({}, {util.inline('spec.dummy.inlineFunction', env)})
  end)
end)
