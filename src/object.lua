local Object = {
  -- Class Meta Table
  __meta = {
    __index = function (table, key)
      local super = rawget(table, 'super')
      return super and key and super[key] or nil
    end,
    __call = function (table, ...)
      local super = rawget(table, 'super')
      return table.__init and table:__init(...) or super and super.__init and super:__init(...) or nil
    end
  },

  -- Returns a class that is a child of self
  extend = function(self)
    local class = {
      super = self,
      __meta = {}
    }
    for key, value in pairs(self.__meta) do class.__meta[key] = value end
    return setmetatable(class, class.__meta)
  end,

  instanceof = function(self, class)
    return (self == class) or (self.static == class) or (self.super ~= nil) and self.super:instanceof(class) or false
  end,

  tostring = function()
    return '::class::'
  end,

  --Constructor
  __init = function(self)
    local newobject = {
      super = self.super,
      static = self,

      -- Instance Meta Table
      __meta = {
        __index = function (table, key)
          local static = rawget(table, 'static')
          local keyget = rawget(table, 'get'..key)
          return keyget or static and key and static['get'..key] or table.__meta.__field[key] or static and key and static[key] or nil
        end,
        __newindex = function(table, key, value)
          if table['set'..key] then
            table['set'..key](value)
          else
            table.__meta.__field[key] = value
          end
        end,
        __field = {}
      },

      tostring = function()
        return '::object::'
      end
    }
    return setmetatable(newobject, newobject.__meta)
  end
}
return setmetatable(Object, Object.__meta)
