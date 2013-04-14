local util = require 'util'

return {
  handler = function(context)
    util.inline(config.file, {context=context})
  end
}
