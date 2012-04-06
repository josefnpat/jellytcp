#!/usr/bin/lua5.1
local json = require("json")

local socket = require("socket")
local server = assert(socket.bind("*", 8080))
local ip, port = server:getsockname()

print("Server hosted on port " .. port)

local time_start
local time_end

local payload = {}

while 1 do
  if not client then
    time_start = socket.gettime()
    client = server:accept()
    client:settimeout(0.001)
  end
  local line, err = client:receive()
  if err then
    print("err:"..err)
  else
    if pcall(function() json.decode(line) end) then
      data = json.decode(line)
      client:send(json.encode(payload).."\n")
      time_end = socket.gettime()
      print("receive:"..line.." ["..(time_end-time_start).."s]")
    else
      print("json.decode() failed")
    end
  end
  client:close()
  client = nil
end

