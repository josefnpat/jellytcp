local jellyclient = {}

-- TODO:
-- * Use assert
-- * internationalize error messages
-- * remove collision possibility of id
-- * use sessions instead of id

jellyclient.defaults = {}
jellyclient.defaults.lower_latency = 1/24

jellyclient.var = {}
jellyclient.var.timeout_connect = 0.1

jellyclient._debug = false

function jellyclient.new(ip,port,op,lower_latency)

  assert(json,"json module not found.")
  assert(socket,"socket module not found.")

  local client = {}
  -- init
  client._lower_latency_dt = 0
  client._payload = {}
  client._debug = jellyclient._debug

  -- args
  client._ip = ip
  client._port = port
  client._op = op
  if not lower_latency or lower_latency < 0 then
    lower_latency = jellyclient.defaults.lower_latency
  end
  client._lower_latency = lower_latency
  
  -- funcs
  client.run = jellyclient.run
  client.update = jellyclient.update
  client.connected = jellyclient.connected
  
  -- connect
  
  if client._debug then print("socket.connect start") end
  local sock,error = socket.connect(ip,port)
  if client._debug then print("socket.connect stop") end
  
  if sock then
    sock:settimeout(jellyclient.var.timeout_connect)
    client._id = math.random(1,99999999)
    client._sock = sock
  else
    client._sock = nil
    return false,error
  end
  
  return client
end

function jellyclient:connected()
  if self._sock then
    return true
  else
    return false
  end
end

function jellyclient:run(fname,data)
  -- if this function is defined and validates
  if self._op[fname] and self._op[fname].validate(data) then
    table.insert(self._payload,{f=fname,d=data})
  end
end

function jellyclient:update(dt)
  self._lower_latency_dt = self._lower_latency_dt + dt
  if self._lower_latency_dt > self._lower_latency then
    self._lower_latency_dt = 0
    
    if self._debug then print("client.sock:send start") end
    self._sock:send(json.encode({id=self._id,data=self._payload}).."\n")
    if self._debug then print("client.sock:send stop") end
    
    if self._debug then print("client.sock:receive start") end
    local line,error = self._sock:receive()
    if self._debug then print("client.sock:receive stop") end
    
    if error then
      if self._debug then print(error) end
      return false,error
    else
      if self._debug then print("response:"..line) end
      if pcall(function() json.decode(line) end) then
        local data = json.decode(line)
        -- operate on the returned ops
        for i,v in pairs(data) do
          -- if there is a client function, f
          if self._op[v.f].client then
            -- run that function with the data, d
            self._op[v.f].client(v.d)
          else
            if self._debug then print("Attempting to respond to "..v.f.." but there is no function defined.") end
          end
        end
      else
        if self._debug then print("json.decode() failed") end
      end
      -- reset the payload
      self._payload = {}
      return true -- the update ran successfully.
    end
    
  end
  
end

return jellyclient
