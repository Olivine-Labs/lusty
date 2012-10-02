local lusty, context = ...
lusty.config('store')
context.store = function(object, method)
  lusty:publish({'store'}, {
    context = context,
    object = object
  })
end
