local lusty, namespace = ...
local db = package.loaders[2]('event.store.mongo.connection')(lusty)
local col = db.get_col(lusty.config[namespace].collection)
return {
  handler = function(context)
    local query, data = context.query, context.data
    local meta = getmetatable(data)
    if type(meta.__toStore) == "function" then
      data = meta.__toStore(data, "patch")
    end
    return col:update(query, data, 0, 1, 1)
  end
}
