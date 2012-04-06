math.randomseed(os.time())

jellyclient = {}

local socket = require("socket")
local json = require("json")

function jellyclient.sleep(sec)
  socket.select(nil, nil, sec)
end

local client

function jellyclient.init()
  jellyclient.payload = {}
  jellyclient.payload.queue = {}
end

jellyclient.init()

local refresh_rate = 0.1
local refresh_dt = 0
function jellyclient.update(dt)
  refresh_dt = refresh_dt + dt
  if refresh_dt > refresh_rate then
    refresh_dt = 0
    client = socket.connect("localhost", 8080)
    if not client then
      print("attempting to connect to server...")  
    else
      client:send(json.encode(jellyclient.payload).."\n") 
      local line, err = client:receive()
      if line then
        print("receive:"..line)
        jellyclient.init()
      elseif err then
        print("err:"..err)
      end
    end    
  end
end

return jellyclient
