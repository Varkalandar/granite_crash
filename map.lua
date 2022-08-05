-- 
-- "Granite Crash" map data and display
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local ffi = require("ffi")

local map = 
{
  C_SPEED = 160,

  M_SPACE = string.byte(" "),
  M_EARTH = string.byte("."),
  M_DIAMOND = string.byte("x"),
  M_ROCK = string.byte("O"),
  M_WALL = string.byte("="),
  M_METAL = string.byte("#"),
  M_BOMBER = string.byte("B"),
  M_REWARD = string.byte("X"),
  M_AMOEBA = string.byte("*"),
  M_PLAYER = string.byte("P"),
  M_EXIT_LOCKED = string.byte("2"),
  M_EXIT_OPEN = string.byte("3"),
  M_BLOCKER = 127
}


local function getCell(x, y)
  local n = 87 + y*(map.columns+1) + x
  
  if n >= 87 and n < 87 + (map.columns+1) * map.rows then
    return map.data[n]  
  end
  
  return map.M_SPACE
end


local function setCell(x, y, c)
  local n = 87 + y*(map.columns+1) + x
  
  if n >= 87 and n < 87 + (map.columns+1) * map.rows then
    map.data[n] = c
  end
end


local function fill(x, y, c)
  for i=-1, 1 do
    for j=-1, 1 do
      map.setCell(x+i, y+j, c)
    end
  end
end


local function loadTiles(path)
  -- local sprites = love.graphics.newImage(path .. "sprites.png")
  local sprites = love.graphics.newImage(path .. "sprites_dark.png")
  
  local quads = {}
  local w = 32;
  
  quads[map.M_METAL] = love.graphics.newQuad(8*w, 0*w, w, w, sprites)
  quads[map.M_EARTH] = love.graphics.newQuad(4*w, 0*w, w, w, sprites)
  quads[map.M_PLAYER] = love.graphics.newQuad(1*w, 0*w, w, w, sprites)
  quads[map.M_EXIT_LOCKED] = love.graphics.newQuad(9*w, 0*w, w, w, sprites)
  quads[map.M_EXIT_OPEN] = love.graphics.newQuad(10*w, 0*w, w, w, sprites)
  quads[map.M_EXIT_OPEN+1] = love.graphics.newQuad(11*w, 0*w, w, w, sprites)
  quads[map.M_ROCK] = love.graphics.newQuad(5*w, 0*w, w, w, sprites)
  quads[map.M_DIAMOND] = love.graphics.newQuad(6*w, 0*w, w, w, sprites)
  quads[map.M_WALL] = love.graphics.newQuad(7*w, 0*w, w, w, sprites)

  for i=0,7 do
    quads[map.M_BOMBER + i] = love.graphics.newQuad(i*w, 1*w, w-1, w-1, sprites)
  end


  quads[map.M_REWARD] = love.graphics.newQuad(9*w, 0*w, w-1, w-1, sprites)
  
  
  quads[map.M_REWARD+0] = love.graphics.newQuad(0*w, 3*w, w-1, w-1, sprites)
  quads[map.M_REWARD+1] = love.graphics.newQuad(1*w, 3*w, w-1, w-1, sprites)
  quads[map.M_REWARD+2] = love.graphics.newQuad(2*w, 3*w, w-1, w-1, sprites)
  quads[map.M_REWARD+3] = love.graphics.newQuad(3*w, 3*w, w-1, w-1, sprites)

  -- quads[map.M_REWARD+0] = love.graphics.newQuad(0*w, 2*w, w-1, w-1, sprites)
  -- quads[map.M_REWARD+1] = love.graphics.newQuad(1*w, 2*w, w-1, w-1, sprites)
  -- quads[map.M_REWARD+2] = love.graphics.newQuad(2*w, 2*w, w-1, w-1, sprites)
  -- quads[map.M_REWARD+3] = love.graphics.newQuad(3*w, 2*w, w-1, w-1, sprites)

  quads[map.M_AMOEBA+0] = love.graphics.newQuad(4*w, 3*w, w, w, sprites)
  quads[map.M_AMOEBA+1] = love.graphics.newQuad(5*w, 3*w, w, w, sprites)
  quads[map.M_AMOEBA+2] = love.graphics.newQuad(6*w, 3*w, w, w, sprites)
  quads[map.M_AMOEBA+3] = love.graphics.newQuad(7*w, 3*w, w, w, sprites)

  -- debug
  -- quads[map.M_BLOCKER] = love.graphics.newQuad(0*w, 1*w, w, w, sprites)
  
  -- debug
  -- quads[map.M_SPACE] = love.graphics.newQuad(3*w, 1*w, w, w, sprites)
  
  map.sprites = sprites
  map.quads = quads
end


local function decimal(n)
  return (map.data[n]-48) * 10 + (map.data[n+1]-48)
end


local function loadLevel(path, filename)
  print("Loading level file " .. path .. filename)
  
  local file, size = love.filesystem.read(path..filename);

  -- print("  read " .. size .. " bytes")

  local bytes = love.data.newByteData(file)  
  
  print("  -> " .. bytes:getSize() .. " bytes")
  
  map.level = file
  -- Löve 11.3
  -- map.data = ffi.cast('uint8_t*', bytes:getFFIPointer())
  map.bytes = bytes
  map.data = ffi.cast('uint8_t*', bytes:getPointer())
  
  map.columns = decimal(81)
  map.rows = decimal(84)
  
  print("Map size is " .. map.columns .. "x" .. map.rows)
  
  map.meta = {}
  
  for line in map.level:gmatch(".-\n") do
    -- table.insert(lines, line:match("[^\n]*"))    
    -- print("-> " .. line)
    
    for word in line:gmatch("gems=.*") do
      map.meta.gems = tonumber(word:sub(6))
      print("Gems needed: " .. map.meta.gems)
    end
  end    
end


local function load()
  loadTiles("resources/gfx/")
  map.time = 0
  map.delta = 0
end


local function turnAmoeabaIntoDiamonds(gameUi)
  local t = { radius=0, type=map.M_DIAMOND }
  
  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = getCell(x, y)      
      if cell == map.M_AMOEBA then
        gameUi.fill(x, y, t)
        sounds.randplay(sounds.gemfall, 1, 0.2)
      end
    end
  end
end


local function growAmoebaCellDirection(x, y, player)
  local amoebaspace = 0
  
  if player.x ~= x or player.y ~= y then  
    local cell = map.getCell(x, y)
    if cell == map.M_EARTH or 
       cell == map.M_SPACE then
      amoebaspace = 1
      if love.math.random() < 0.05 then
        sounds.randplay(sounds.walk, 0.3, 0.02)      
        map.setCell(x, y, map.M_AMOEBA)
      end
    end
  end
  
  return amoebaspace
end


local function growAmoebaCell(x, y, player)
  local as = growAmoebaCellDirection(x-1, y, player)
  as = as + growAmoebaCellDirection(x+1, y, player)
  as = as + growAmoebaCellDirection(x, y-1, player)
  as = as + growAmoebaCellDirection(x, y+1, player)
  return as
end


local function growAmoeba(gameUi, player)
  local as = 0

  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = getCell(x, y)
      
      if cell == map.M_AMOEBA then
        as = as + growAmoebaCell(x, y, player)
      end
    end
  end
  
  -- was there space to grow into?
  if as == 0 then
    -- no space. Turn amoeba into diamonds
    turnAmoeabaIntoDiamonds(gameUi)
  end
end


local function update(gameUi, time, dt, player)
  map.time = time
  map.delta = map.delta + dt
  
  if map.delta > 0.2 then
    growAmoeba(gameUi, player)
    map.delta = 0
  end
end


local function draw(xoff, yoff)  
  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = getCell(x, y)
      
      local quad = map.quads[cell]
      
      if quad and cell ~= map.M_ROCK and cell ~=map.M_DIAMOND then
      
        -- make exit blink
        if cell == map.M_EXIT_OPEN then
          local offset = math.floor(map.time * 10) % 2
          quad = map.quads[cell+offset]
        end
        
        if cell == map.M_AMOEBA then
          local offset = math.floor(map.time * 4) % 4
          quad = map.quads[cell+offset]
        end
        
        love.graphics.draw(map.sprites, quad, 
                           xoff + x*map.raster, yoff + y*map.raster, 
                           0, 1, 1, 0, 0, 0, 0)
      end
    end
  end
end


local function drawFull(xoff, yoff)  
  for y=0, map.rows-1 do
    for x=0, map.columns-1 do
      local cell = getCell(x, y)
      
      local quad = map.quads[cell]
      
      if quad then
        love.graphics.draw(map.sprites, quad, 
                           xoff + x*map.raster, yoff + y*map.raster, 
                           0, 1, 1, 0, 0, 0, 0)
      end
    end
  end
end


map.raster = 32
map.load = load
map.update = update
map.draw = draw
map.drawFull = drawFull

map.getCell = getCell
map.setCell = setCell
map.fill = fill
map.loadLevel = loadLevel

return map
