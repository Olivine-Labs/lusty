local util = require 'util'

return {
  handler = function(context)
    util.inline(config.file, {config=config, context=context})
  end
}
