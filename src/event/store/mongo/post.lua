local lusty, namespace = ...
local db = package.loaders[2]('event.store.mongo.connection')(lusty)
local col = db.get_col(lusty.config[namespace].collection)
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
