local lusty, context = ...
lusty.config('store')

local store = function(method)
  return function(query)
    lusty:publish({'store', method}, query)
  end
end

context.store = setmetatable({},
{
  __index = function(self, key)
    local val = rawget(self, key)
    if not val then
      self[key] = store(key)
    else
      return self[key]
    end
  end
})
