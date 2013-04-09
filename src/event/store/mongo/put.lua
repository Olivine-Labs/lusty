local lusty, config = ...
local db = lusty.requireArgs('event.store.mongo.connection', lusty)
local col = db.get_col(config.collection)
return {
  handler = function(context)
    local query, data = context.query, context.data
    local meta = getmetatable(data)
    if type(meta.__toStore) == "function" then
      data = meta.__toStore(data, "put")
    end
    return col:update(query, data, 1, 0, 1)
  end
}
