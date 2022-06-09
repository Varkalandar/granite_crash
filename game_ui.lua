-- 
-- "Granite Crash" game input controller
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local player = require("player")
local rocks = require("rocks")
local swarm = require("swarm")
local pixfont = require("pixfont")

local gameUi = {}


local function explode(x, y, type)
  local map = gameUi.map
  sounds.randplay(sounds.bang, 1, 0)

  local c = map.M_DIAMOND  
  if type == map.M_BOMBER then      
    c = map.M_SPACE
  end

  for i=-1, 1 do
    for j=-1, 1 do
      local nx = x+i
      local ny = y+j
      
      swarm.remove(nx, ny)
      rocks.remove(nx, ny)
      map.setCell(nx, ny, c)
      
      if c == map.M_DIAMOND then
        rocks.add(nx, ny, c)
      end
    end
  end
end


local function scanMap()
  local map = gameUi.map

  -- scan the level for a player tile

  -- print("PC=" .. pc)

  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = map.getCell(x, y)
      if cell == map.M_PLAYER then
        player.x = x
        player.y = y
		    map.setCell(x, y, map.M_SPACE)
	    elseif cell == map.M_BOMBER then
	      swarm.add(x, y, cell)
		    map.setCell(x, y, map.M_SPACE)
	    elseif cell == map.M_REWARD then
	      swarm.add(x, y, cell)	  
        map.setCell(x, y, map.M_SPACE)
	    elseif cell == map.M_ROCK then
	      rocks.add(x, y, cell)	  
	    elseif cell == map.M_DIAMOND then
	      rocks.add(x, y, cell)	  
      end
    end
  end

  print("Found player at " .. player.x .. ", " .. player.y)
end


local function load(map)
  player.load(map)
  rocks.load(map)
  swarm.load(map)

  gameUi.map = map
  gameUi.swarm = swarm

  -- pixfont = pixfont.init("resources/font/humanistic_128bbl")
  pixfont = pixfont.init("resources/font/sans_serif")
  
  scanMap()
end


local function update(time, dt)
  gameUi.time = time
  
  local map = gameUi.map 
  map.update(time, dt)
  player.update(time, dt, rocks)
  swarm.update(time, dt, map.C_SPEED)
  rocks.update(time, dt, player, gameUi)

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
      player.go(time, vx, vy, rocks)
    else
      player.push = 0
      player.pushdir = 0
    end
  end
  
  swarm.collisions(map, player, gameUi)
end


local function draw()

  local xoff = 400 - player.x * gameUi.map.raster
  local yoff = 290 - player.y * gameUi.map.raster
  
  xoff = math.floor(xoff - player.xoff)
  yoff = math.floor(yoff - player.yoff)

  love.graphics.setColor(0.9, 0.9, 0.9, 1)

  gameUi.map.draw(xoff, yoff)
  rocks.draw(xoff, yoff)
  swarm.draw(xoff, yoff)
  player.draw(gameUi.time, 400, 290)

  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

  -- love.graphics.print("Diamonds: " .. player.diamonds.collected .. "/" .. player.diamonds.required, 690, 10)
  
  love.graphics.setColor(0.5, 1.0, 0.0, 1)
  pixfont:drawStringScaled("Gems: " .. player.diamonds.collected .. "/" .. player.diamonds.required, 10, 10, 0.3, 0.3)
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

gameUi.explode = explode

gameUi.mousePressed = mousePressed
gameUi.mouseReleased = mouseReleased
gameUi.mouseDragged = mouseDragged
gameUi.keyReleased = keyReleased

return gameUi
