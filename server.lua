#!/usr/bin/lua5.1

local json = require("json")

local socket = require("socket")
local server = assert(socket.bind("*", 8080))
local ip, port = server:getsockname()

print("Server hosted at " .. ip .. ":" .. port)

while 1 do
  if not client then
    client = server:accept()
    client:settimeout(1)
  end
  local line, err = client:receive()
  if err then
    print("err:"..err)
  else
    data = json.decode(line)
    client:send("Hello Client "..data.id.."\n")
    print("receive:"..line)
  end
  client:close()
  client = nil
end
