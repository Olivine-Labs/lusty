local lusty, namespace = ...
local db = package.loaders[2]('event.store.mongo.connection')(lusty)
local col = db.get_col(lusty.config[namespace].collection)
return {
  handler = function(context)
    return col:insert({context.query}, 0, 1)
  end
}
