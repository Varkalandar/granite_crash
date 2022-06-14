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
  M_BOMBER = string.byte("W"),
  M_REWARD = string.byte("X"),
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
  local sprites = love.graphics.newImage(path .. "sprites.png")
  
  local quads = {}
  local w = 32;
  
  quads[map.M_METAL] = love.graphics.newQuad(8*w, 0*w, w, w, sprites)
  quads[map.M_EARTH] = love.graphics.newQuad(4*w, 0*w, w, w, sprites)
  quads[map.M_PLAYER] = love.graphics.newQuad(1*w, 0*w, w, w, sprites)
  quads[map.M_EXIT_LOCKED] = love.graphics.newQuad(6*w, 1*w, w, w, sprites)
  quads[map.M_EXIT_OPEN] = love.graphics.newQuad(7*w, 1*w, w, w, sprites)
  quads[map.M_EXIT_OPEN+1] = love.graphics.newQuad(8*w, 1*w, w, w, sprites)
  quads[map.M_ROCK] = love.graphics.newQuad(5*w, 0*w, w, w, sprites)
  quads[map.M_DIAMOND] = love.graphics.newQuad(6*w, 0*w, w, w, sprites)
  quads[map.M_WALL] = love.graphics.newQuad(7*w, 0*w, w, w, sprites)

  quads[map.M_BOMBER] = love.graphics.newQuad(0*w, 0*w, w-1, w-1, sprites)
  quads[map.M_BOMBER] = love.graphics.newQuad(11*w, 2*w, w-1, w-1, sprites)


  quads[map.M_REWARD] = love.graphics.newQuad(9*w, 0*w, w-1, w-1, sprites)
  
  
  -- quads[map.M_REWARD] = love.graphics.newQuad(2*w, 1*w, w-1, w-1, sprites)
  quads[map.M_REWARD+1] = love.graphics.newQuad(3*w, 1*w, w-1, w-1, sprites)
  quads[map.M_REWARD+2] = love.graphics.newQuad(4*w, 1*w, w-1, w-1, sprites)
  quads[map.M_REWARD+3] = love.graphics.newQuad(5*w, 1*w, w-1, w-1, sprites)

  quads[map.M_REWARD] = love.graphics.newQuad(4*w, 2*w, w-1, w-1, sprites)
  quads[map.M_REWARD+1] = love.graphics.newQuad(5*w, 2*w, w-1, w-1, sprites)
  quads[map.M_REWARD+2] = love.graphics.newQuad(6*w, 2*w, w-1, w-1, sprites)
  quads[map.M_REWARD+3] = love.graphics.newQuad(7*w, 2*w, w-1, w-1, sprites)

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
  -- loadLevel("resources/maps/", "1.map")  
  -- loadLevel("resources/maps/", "40x22.map")  
end


local function update(time, dt)
  map.time = time
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
