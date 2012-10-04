local lusty, namespace = ...
local db = package.loaders[2]('event.store.mongo.connection')(lusty)
local col = db.get_col(lusty.config[namespace].collection)
return {
  handler = function(context)
    local query, data = context.query, context.data
    return col:find(query, data)
  end
}
