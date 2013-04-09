package = "lusty"
version = "0.1-0"
source = {
  url = "https://github.com/Olivine-Labs/lusty/v0.1.tar.gz",
  dir = "lusty"
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
  "lua_cliargs >= 2.0",
  "dkjson >= 2.1.0",
  "busted >= 1.6-1"
}
build = {
  type = "builtin",
  modules = {
  },
  install = {
    bin = {
      ["busted"] = "bin/lusty",
      ["busted.bat"] = "bin/lusty.bat",
      ["lusty_bootstrap"] = "bin/lusty_bootstrap"
    }
  }
}
