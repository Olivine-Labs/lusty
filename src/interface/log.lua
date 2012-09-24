local lusty, context = ...
lusty.config('log')
context.log = function(message, level)
  if not level then level = 'debug' end
  lusty:publish({'log', level}, {
    context = context,
    message = message,
    level = level
  })
end
