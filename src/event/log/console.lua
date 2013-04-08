return {
  handler = function(context)
    print((context.level or "debug")..'::'..(context.message or "no message"))
  end
}
