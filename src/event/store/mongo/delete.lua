local lusty, config = ...
local db = lusty.requireArgs('event.store.mongo.connection', lusty, config)
local col = db.get_col(config.collection)

return {
  handler = function(context)
    return col:delete(context.query, 0, 1)
  end
}
