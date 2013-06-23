local ops = {}

ops.test = {}

ops.test.server = function(clientid,data)
  local ret = "ABC"..math.random(100,999)
  print("-- incoming clientid:",clientid)
  print("-- incoming data:",data)
  print("-- outgoing data:",ret)
  for i = 1,50000 do
    ret = ret .. math.random(1,100)
  end
  return ret .. "END"
end

ops.test.client = function(data)
  print("-- incoming data:",data)
end

ops.test.validate = function(data)
  if type(data) == "string" then
    print("-- data validated:",data)
    return true
  end
end

return ops
