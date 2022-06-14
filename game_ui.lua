-- 
-- "Granite Crash" game input controller
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local player = require("player")
local rocks = require("rocks")
local swarm = require("swarm")
local animations = require("animations")
local pixfont = require("pixfont")

local gameUi = {}


local function fill(x, y, params)
  local map = gameUi.map
  
  for i=-1, 1 do
    for j=-1, 1 do
      local nx = x+i
      local ny = y+j
      
      -- metal is indestructible
      if map.getCell(nx, ny) ~= map.M_METAL then
        map.setCell(nx, ny, params.type)
        rocks.add(nx, ny, params.type)
      end
    end
  end
end


local function explode(x, y, type)
  local map = gameUi.map
  sounds.randplay(sounds.bang, 1, 0)

  local c = map.M_SPACE

  for i=-1, 1 do
    for j=-1, 1 do
      local nx = x+i
      local ny = y+j
      
      -- metal is indestructible
      if map.getCell(nx, ny) ~= map.M_METAL then
        swarm.remove(nx, ny)
        rocks.remove(nx, ny)
        map.setCell(nx, ny, c)
      end
    end
  end

  if type == map.M_REWARD then
    animations.make(fill, x, y, 1, {type = map.M_DIAMOND })  
  else
    animations.make(nil, x, y, 1, nil)  
  end
end


local function scanMap()
  local map = gameUi.map

  -- start with fresh tables
  swarm.mobs = {}
  rocks.mobs = {}
  
  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = map.getCell(x, y)
      if cell == map.M_PLAYER then
        player.x = x
        player.y = y
        map.setCell(x, y, map.M_SPACE)
      elseif cell == map.M_EXIT_LOCKED then
        player.exit = {x=x, y=y}
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
  print("Found exit at " .. player.exit.x .. ", " .. player.exit.y)
  
  player.diamonds.required = map.meta.gems
  player.diamonds.collected = 0
end


local function load(map)

  levels =
  {
    "spiral.map",
    "silos.map",
    "40x22.map",
    "1.map"
  }

  colors =
  {
    {r=0.9, g=0.9, b=0.9},
    {r=1.0, g=0.9, b=0.5},
    {r=1.0, g=0.7, b=0.75},
    {r=0.85, g=0.80, b=1.0},
  }
  
  gameUi.levels = levels
  gameUi.colors = colors
  player.level = 1
  map.loadLevel("resources/maps/", levels[player.level]) 

  player.load(map)
  rocks.load(map)
  swarm.load(map)
  animations.load()
  
  gameUi.map = map
  gameUi.swarm = swarm

  pixfont = pixfont.init("resources/font/sans_serif")
  
  gameUi.title = love.graphics.newImage("resources/gfx/title.png")  
  
  scanMap()
end


local function newLevel()
  player.level = player.level + 1
  local map = gameUi.map 
  map.loadLevel("resources/maps/", levels[player.level])
  scanMap()
end


local function update(time, dt)
  gameUi.time = time
  
  local map = gameUi.map 
  map.update(time, dt)
  player.update(time, dt, rocks)
  swarm.update(time, dt, map.C_SPEED)
  rocks.update(time, dt, player, gameUi)
  animations.update(time, dt)
  
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
  
  -- open the exit?
  if player.diamonds.collected >= player.diamonds.required and
     map.getCell(player.exit.x, player.exit.y) == map.M_EXIT_LOCKED then
    sounds.randplay(sounds.level, 1, 0)
    map.setCell(player.exit.x, player.exit.y, map.M_EXIT_OPEN)
  end
  
  -- reached the exit?
  if player.x == player.exit.x and player.y == player.exit.y then
    newLevel()
  end

  -- player died?
  if not player.alive then
    if love.keyboard.isDown("escape") then
      player.lives = player.lives - 1
      player.level = player.level - 1
      newLevel()
      player.alive = true
      
    end
  end
  
  
  -- player died?
  if player.lives < 1 then
    player.level = 0
    newLevel()
    player.lives = 5
  end
end


local function draw()

  local xoff = 400 - player.x * gameUi.map.raster
  local yoff = 290 - player.y * gameUi.map.raster
  
  xoff = math.floor(xoff - player.xoff)
  yoff = math.floor(yoff - player.yoff)

  local color = gameUi.colors[player.level]
  
  love.graphics.setColor(color.r, color.g, color.b, 1)

  gameUi.map.draw(xoff, yoff)
  rocks.draw(xoff, yoff)
  swarm.draw(xoff, yoff)
  player.draw(gameUi.time, 400, 290)
  animations.draw(xoff, yoff)

  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

  -- love.graphics.setColor(0, 0, 0, 1)
  -- love.graphics.rectangle("fill", 0, 0, 800, 42)
  love.graphics.setColor(0.5, 0.4, 0.5, 1)
  love.graphics.draw(gameUi.title, 0, 0)
  
  love.graphics.setColor(0.5, 1.0, 0.0, 1)
  pixfont:drawStringScaled("Gems: " .. player.diamonds.collected .. "/" .. player.diamonds.required, 10, 5, 0.3, 0.3)
  pixfont:drawStringScaled("Lives: " .. player.lives, 200, 5, 0.3, 0.3)
  pixfont:drawStringScaled("Level: " .. player.level, 400, 5, 0.3, 0.3)
  pixfont:drawStringScaled("Score: " .. player.score, 600, 5, 0.3, 0.3)

  if player.lives <= 1 and not player.alive then
    love.graphics.setColor(1.9, 0.5, 0.0, 1)
    pixfont:drawStringScaled("Game Over", 170, 200, 1, 1)
  end  
  
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
