#!/usr/bin/lua5.1

require "json"
require "socket"

jellyclient = require('jelly.client')
ops = require('ops')

client,error = jellyclient.new("localhost",19870,ops)

if error then
  print(error)
end
client:run('test','Hello World')

function love.update(dt)
  while #client._payload > 0 do
    client:update(dt)
  end
end