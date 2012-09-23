return function(self, message, level)
  if not level then level = 'debug' end
  self:publish({'log'}, {
    lusty = self,
    message = message,
    level = level
  })
end
