local jellyserver = {}

jellyserver._debug = false

jellyserver.var = {}
jellyserver.var.timeout_server = 0.01
jellyserver.var.timeout_client = 0.01

function jellyserver.new(port,op)

  assert(json,"json module not found.")
  assert(socket,"socket module not found.")

  local server = {}

  -- init
  server._debug = jellyserver._debug
  server._clients = {}
  
  -- args
  server._port = port
  server._op = op

  -- funcs
  server.update = jellyserver.update
  
  -- server
  server._sock = assert(socket.bind("*", port))
  server._sock:settimeout(jellyserver.var.timeout_server)
  
  print("Server hosted on port " .. port)
  
  return server
end

function jellyserver:update()

  local client,error = self._sock:accept()
  if client then
    client:settimeout(jellyserver.var.timeout_client)
    table.insert(self._clients,client)
    print("User connected [client count:"..#self._clients.."]")
  else
    if self._debug then print("accept error:"..error) end
  end

  if self._debug then
    print("clients:")
    for clienti,client in ipairs(self._clients) do
      print(clienti,client)
    end
  end

  for clienti,client in ipairs(self._clients) do

    if self._debug then print(clienti.." client:receive start") end
    local line,error = client:receive()
    if self._debug then print(clienti.." client:receive stop") end
    
    if error then
    
      if error == "closed" then
        client:close()
        table.remove(self._clients,clienti)
        print("User disconnected [client count:"..#self._clients.."]")
      end
      if self._debug then print("receive error:"..error) end
      
    else
      if pcall(function() json.decode(line) end) then
        local dataline = json.decode(line)

        if self._debug then print("update start") end
        
        local response = {}
        for i,v in pairs(dataline.data) do
          if self._op[v.f] and self._op[v.f].validate(v.d) then
            local ret = self._op[v.f].server(dataline.id,v.d)
            table.insert(response,{f=v.f,d=ret})
          end
        end
        
        if self._debug then print("update stop") end
        
        if self._debug then print(clienti.." client:send start") end
        client:send(json.encode(response).."\n")
        if self._debug then print(clienti.." client:send stop") end
        
        if self._debug then print("receive:"..line) end
      else
        if self._debug then print("json.decode() failed") end
      end
    end
    
  end
  
end

return jellyserver
