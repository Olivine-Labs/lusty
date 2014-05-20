Lusty
====

An extensible and speedy web framework.

## Description

Provides an event-based system to respond to events, such as HTTP requests.
Built as many decoupled modules. Each module is set up to listen to and submit
data to other modules via channels.

## Installation

Install with luarocks: `luarocks install lusty`
Lusty has a depdendency on mediator\_lua, also available through luarocks.
`luarocks install mediator\_lua`.

[OpenResty](http://www.openresty.com) is nginx + lua, and is the currently
supported server. Apache and IIS will be coming in later versions.

We also suggest you install lusty\_admin, which will help you run a
development server and bootstrap applications. `luarocks install lusty\_admin`
will get you started. You can then call `lusty\_admin init` and `lusty\_admin
server` to bootstrap and fire up OpenResty for testing. `lusty\_admin bootstrap`
will set you up with a very basic listy installation. *Bootstrap assumes OpenResty,
lua, luarocks, mongodb, and git are installed.*

## Usage

Channels control everything. Data persistance, for example, is handled through
a series of pub / sub calls:

```lua
-- data.persistence.user.config - set up channels to listen to

{
  events = {
    ["data:request:user:get"] =  "data.persistance.user#get_user",
    ["data:request:user:save"] =  "data.persistance.user#save_user",
    ["data:request:user:delete"] =  "data.persistance.user#delete_user"
  }
}

-- data.persistence.user.lua
local get_user = function(lusty, parameters, callback)
  local user = {}
  -- get user from mongodb, or mysql, or redis, or wherever
  -- return the user (added to results sent back) and "true", which tells lusty
  -- to continue on to the next event, if it needs to
  return user, true
end

local save_user = function(lusty, user, callback)
  local user = {}
  -- save user to your data store
  return user, true
end

local delete_user = function(lusty, id, callback)
  local user = {}
  -- save user from your data store
  return user, true
end
```

This pattern allows you to use any data store, and encourages building
asynchronous applications to build super efficient applications. The same
pattern is used for handling http events, logging, and anywhere else you'd use
inter-module communication. You can also generate your own channels and
publish / subscribe on any arbitrary channel.

### Event Management

Events are namespaced. Calling "data:store:user" will call everything
subscribing to "data:store:user", as well as all parent channels ("data:store"
and "data").

## License

Copyright 2013 Olivine Labs, LLC.

[MIT licensed](http://www.opensource.org/licenses/mit-license.php).

