#!/usr/bin/lua5.1

require "json"
require "socket"

jellyserver = require('jelly.server')
ops = require('ops')

server = jellyserver.new(19870,ops)

while 1 do
  server:update()
end
