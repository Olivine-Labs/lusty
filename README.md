Lusty
====

An extensible and speedy web framework.

## Description

Provides an event-based system to respond to events, such as HTTP requests.
Built as many decoupled modules. Each module is set up to listen to and submit
data to other modules via channels.

## Installation

Install with luarocks: `luarocks install lusty`
Lusty has a depdendency on mediator\_lua, also avaiable through luarocks.
`luarocks install mediator\_lua`.

[OpenResty](http://www.openresty.com) is nginx + lua, and is the currently
supported server. Apache and IIS will be coming in later versions.

We also suggest you install lusty\_admin, which will help you run a
development server and bootstrap applications. `luarocks install lusty\_admin`
will get you started. You can then call `lusty\_admin init` and `lusty\_admin
server` to bootstrap and fire up OpenResty for testing. `lusty\_admin bootstrap`
will set you up with a very basic listy installation. *Bootstrap assumes OpenResty,
lua, luarocks, mongodb, and git are isntalled.*

## Usage

Channels control everything. Data persistance, for example, is handled through
a series of pub / sub calls:

```lua
# data.persistence.user.config - set up channels to listen to

{
  events = {
    ["data:request:user:get"] =  "get_user",
    ["data:request:user:save"] =  "save_user",
    ["data:request:user:delete"] =  "delete_user"
  }
}

# data.persistence.user.lua
local get_user = function(lusty, parameters, callback)
  # get user from mongodb, or mysql, or redis, or wherever
  lusty.request.events.publish("data:response:user:get", user)
end

local save_user = function(lusty, user, callback)
  # ...
end

local delete_user = function(lusty, id, callback)
  # ...
end

return get_user, save_user, delete_user
```

This pattern allows you to use any data store, and encourages building
asynchronous applications to build super efficient applications. The same
pattern is used for handling http events, logging, and anywhere else you'd use
inter-module communication. You can also generate your own channels and
publish / subscribe on any arbitrary channel.

### Event Management

Events are namespaced. Calling "data:store:user" will call everything
subscribing to "data:store:user", as well as all sub-channels. To enable global
listening, it will also call "data:store" and "data" subscribers (but not
sub-channels.)

## License

Copyright 2013 Olivine Labs, LLC.

[MIT licensed](http://www.opensource.org/licenses/mit-license.php).
