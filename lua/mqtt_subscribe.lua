#!/usr/bin/lua
-- ------------------------------------------------------------------------- --
-- mqtt_subscribe.lua
-- ~~~~~~~~~~~~~~~~~~
-- Please do not remove the following notices.
-- Copyright (c) 2011 by Geekscape Pty. Ltd.
-- Documentation: http://http://geekscape.github.com/lua_mqtt_client
-- License: GPLv3 http://geekscape.org/static/aiko_license.html
-- Version: 0.0 2011-07-28
--
-- Description
-- ~~~~~~~~~~~
-- Subscribe to an MQTT topic and display any received messages.
--
-- References
-- ~~~~~~~~~~
-- Lapp Framework: Lua command line parsing
--   http://lua-users.org/wiki/LappFramework
--
-- ToDo
-- ~~~~
-- None, yet.
-- ------------------------------------------------------------------------- --

function callback(
  topic,    -- string
  message)  -- string

  print("Topic: " .. topic .. ", message: '" .. message .. "'")
end

-- ------------------------------------------------------------------------- --

function is_openwrt()
  return(os.getenv("USER") == "root")  -- Assume logged in as "root" on OpenWRT
end

-- ------------------------------------------------------------------------- --

print("[mqtt_subscribe v0.0 2011-07-28]")

if (not is_openwrt()) then require("luarocks.require") end
require("lapp")

local args = lapp [[
  Subscribe to a specified MQTT topic
  -d,--debug                                Verbose console logging
  -h,--host          (default localhost)    MQTT server hostname
  -i,--id            (default MQTT client)  MQTT client identifier
  -k,--keepalive     (default 60)           Send MQTT PING period (seconds)
  -p,--port          (default 1883)         MQTT server port number
  -t,--topic         (string)               Subscription topic
  -w,--will_message  (default .)            Last will and testament message
  -w,--will_qos      (default 0)            Last will and testament QOS
  -w,--will_retain   (default 0)            Last will and testament retention
  -w,--will_topic    (default .)            Last will and testament topic
]]

local MQTT = require("mqtt_library")

if (args.debug) then MQTT.Utility.set_debug(true) end

if (args.keepalive) then MQTT.client.KEEP_ALIVE_TIME = args.keepalive end

local mqtt_client = MQTT.client.create(args.host, args.port, callback)

if (args.will_message == "."  or  args.will_topic == ".") then
  mqtt_client:connect(args.id)
else
  mqtt_client:connect(
    args.id, args.will_topic, args.will_qos, args.will_retain, args.will_message
  )
end

mqtt_client:subscribe({args.topic})

while (true) do
  mqtt_client:handler()
  socket.sleep(1.0)  -- seconds
end

mqtt_client:unsubscribe({args.topic})

mqtt_client:destroy()

-- ------------------------------------------------------------------------- --