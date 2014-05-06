package = "lusty"
version = "1.0-0"
source = {
  url = "https://github.com/Olivine-Labs/lusty/archive/v1.0.tar.gz",
  dir = "lusty-1.0"
}
description = {
  summary = "Lua web framework.",
  detailed = [[
    An event-based web framework built for speed.
  ]],
  homepage = "http://olivinelabs.com/lusty/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.10-0",
  "mediator_lua >= 1.1-2"
}
build = {
  type = "builtin",
  modules = {
    ["lusty.init"] = "src/init.lua",
    ["lusty.util"] = "src/util.lua"
  }
}
