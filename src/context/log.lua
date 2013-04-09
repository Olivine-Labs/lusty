local context, config = ...

local levels = {
  debug   = 1,
  info    = 2,
  warning = 3,
  error   = 4
}

context.log = function(message, level)

  if not level then level = 'debug' end

  if levels[config.level] >= levels[level] then
    context.lusty:publish({'log', level}, {
      context = context,
      message = message,
      level = level
    })
  end

end
