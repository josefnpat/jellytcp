#!/usr/bin/lua5.1

local socket = require("socket")
local json = require("json")

function sleep(sec)
  socket.select(nil, nil, sec)
end

math.randomseed(os.time())
payload = {}
payload.id = math.random(1,255)

while 1 do
  client = socket.connect("localhost", 8080)
  client:send(json.encode(payload).."\n") 
  local line, err = client:receive()
  if line then print("receive:"..line) end
  if err then print("err:"..err) end
--  sleep(1)
end


