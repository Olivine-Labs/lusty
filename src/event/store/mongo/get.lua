local lusty, config = ...
local db = lusty.requireArgs('event.store.mongo.connection', lusty, config)
local col = db.get_col(config.collection)

return {
  handler = function(context)
    local query, data = context.query, context.data
    return col:find(query, data)
  end
}
