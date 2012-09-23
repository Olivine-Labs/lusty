return {
  handler = function(context)
    print(context.level..'::'..context.message)
  end
}
