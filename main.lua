jellyclient = require("jellyclient")

function love.update(dt)
  jellyclient.update(dt)
end

id = math.random(1,255)

function love.mousepressed(x,y,button)
  data = {}
  data.x = x
  data.y = y
  jellyclient.payload.id = id
  table.insert(jellyclient.payload.queue,data)
end

