local player = require("player")
local swarm = require("swarm")

local gameUi = {}

local function scanMap()
  local map = gameUi.map

  -- scan the level for a player tile

  -- print("PC=" .. pc)

  for y=0, 39 do
    for x=0, 79 do
      local cell = map.getCell(x, y)
      if cell == map.M_PLAYER then
        player.x = x
        player.y = y
		    map.setCell(x, y, map.M_SPACE)
	    elseif cell == map.M_BOMBER then
	      swarm.add(x, y, cell)
		    gameUi.map.setCell(x, y, map.M_SPACE)
	    elseif cell == map.M_REWARD then
	      swarm.add(x, y, cell)	  
        gameUi.map.setCell(x, y, map.M_SPACE)
      end
    end
  end

  print("Found player at " .. player.x .. ", " .. player.y)
end


local function load(map)
  gameUi.map = map
  player.load(map)
  swarm.load(map)
  
  scanMap()
end


local function update(time, dt)
  local map = gameUi.map 
  map.update(time, dt)
  player.update(time, dt, map.C_SPEED)
  swarm.update(time, dt, map.C_SPEED)

  local vx = 0;
  local vy = 0;

  if love.keyboard.isDown("right") then  
    vx = 1
  elseif love.keyboard.isDown("left") then
    vx = -1
  elseif love.keyboard.isDown("up") then
    vy = -1
  elseif love.keyboard.isDown("down") then
    vy = 1
  end
  
  if player.time == 0 then
  
    -- gameUi.map.setCell(player.x, player.y, map.M_SPACE)
  
    -- new move?
    if vx ~= 0 or vy ~= 0 then
      player.go(time, vx, vy)
    end
  end
  
  swarm.collisions(map, player)  
end


local function draw()

  local xoff = 400 - player.x * gameUi.map.raster
  local yoff = 290 - player.y * gameUi.map.raster
  
  xoff = math.floor(xoff - player.xoff)
  yoff = math.floor(yoff - player.yoff)

  gameUi.map.draw(xoff, yoff)
  swarm.draw(xoff, yoff)
  player.draw(400, 290)

  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

  love.graphics.print("Diamonds: " .. player.diamonds.collected .. "/" .. player.diamonds.required, 690, 10)
  
end


local function mousePressed(button, mx, my)
end


local function mouseReleased(button, mx, my)
end


local function mouseDragged(button, mx, my)
end


local function keyReleased(key, scancode, isrepeat)
end



gameUi.load = load
gameUi.update = update
gameUi.draw = draw

gameUi.mousePressed = mousePressed
gameUi.mouseReleased = mouseReleased
gameUi.mouseDragged = mouseDragged
gameUi.keyReleased = keyReleased

return gameUi
