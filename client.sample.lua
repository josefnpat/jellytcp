#!/usr/bin/lua5.1

require "json"
require "socket"

jellyclient = require('jelly.client')
ops = require('ops')

client,error = jellyclient.new("localhost",19870,ops)

if error then
  print(error)
else
  client:run('test','Hello World')
  now = socket.gettime()
  last = socket.gettime()
  while #client._payload > 0 do
    last = now
    now = socket.gettime()
    client:update(now - last)
  end
end