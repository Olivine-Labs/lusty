local lusty, config = ...
local db = lusty.requireArgs('event.store.mongo.connection', lusty, config)
local col = db.get_col(config.collection)

return {
  handler = function(context)
    local data = context.query
    local meta = getmetatable(data)
    if type(meta.__toStore) == "function" then
      data = meta.__toStore(data, "post")
    end
    return col:insert({data}, 0, 1)
  end
}
