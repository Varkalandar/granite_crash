local player = {}

local function push(map, time, dx, dy, rocks)
  -- are we pushing already?
  if player.push > 0 then
    -- did we push long enough?
    if time - player.push > 1.0 then
      local nx = player.x + dx
      local ny = player.y + dy
      
      -- is there pace to push into?
      if map.getCell(nx + dx, ny + dy) == map.M_SPACE then
        -- update rock data
        local rock = rocks.get(nx, ny)
        rock.x = nx + dx
        rock.y = ny + dy

        -- update map data
        map.setCell(nx, ny, map.M_SPACE)
        map.setCell(rock.x, rock.y, map.M_ROCK)
        
        sounds.randplay(sounds.walk, 0.7, 0.05)
        
        -- prepare for a new push
        player.push = 0
        player.pushdir = 0
      end      
    end
  else
    -- new pushing attempt
    player.push = time
    player.pushdir = dx
  end
end


local function go(time, dx, dy, rocks)
  local map = player.map
  
  -- is the move possible?
  local nx = player.x + dx
  local ny = player.y + dy
  
  local cell = map.getCell(nx, ny)
  
  if cell == map.M_SPACE or
     cell == map.M_EARTH or
     cell == map.M_DIAMOND then
  
    player.dx = dx
    player.dy = dy
    player.xoff = 0
    player.yoff = 0
    player.time = time
    player.push = 0
    player.pushdir = 0    
  elseif cell == map.M_ROCK then
    push(map, time, dx, dy, rocks)
  end
end


local function load(map)
  -- player images

  local image = love.graphics.newImage("resources/gfx/player.png")  
  local quads = {}
  local w = 32;
  
  -- alive
  for i=0,11 do
    quads[i] = love.graphics.newQuad(i*w, 1*w, w, w, 12*w, 2*w)
  end
  
  -- dead
  quads[12] = love.graphics.newQuad(0*w, 0*w, w, w, 12*w, 2*w)

  -- idle
  quads[13] = love.graphics.newQuad(1*w, 0*w, w, w, 12*w, 2*w)

  
  player.sprites = image
  player.quads = quads
  player.alive = true
  
  -- player map position
  player.x = 0
  player.y = 0
  
  -- player pixel move (0 ... raster)
  player.dx = 0
  player.dy = 0
  player.xoff = 0
  player.yoff = 0
  player.time = 0
  player.push = 0
  player.pushdir = 0    
  
  player.diamonds =
  {
    required = 40,
    collected = 0
  }
  
  player.map = map
end


local function collect(rocks)
  local map = player.map
  local cell = map.getCell(player.x, player.y)   

  if cell == map.M_DIAMOND then
    sounds.randplay(sounds.pick, 1, 0.1)
    local diamonds = player.diamonds
    diamonds.collected = diamonds.collected + 1
    rocks.remove(player.x, player.y, map.M_SPACE)
  elseif cell == map.M_EARTH then
    sounds.randplay(sounds.walk, 1, 0.1)
  end

  map.setCell(player.x, player.y, map.M_SPACE)
end


local function update(time, dt, rocks)
  local delta = (time - player.time) * player.map.C_SPEED 

  -- move finished?  
  if delta > 31 then	
    player.x = player.x + player.dx
    player.y = player.y + player.dy
    player.dx = 0
    player.dy = 0  
    player.xoff = 0
    player.yoff = 0
    player.time = 0
  
    collect(rocks)
  
  else  
    player.xoff = player.dx * delta
    player.yoff = player.dy * delta
  end
  
end


local function draw(time, x, y)
  if player.alive then
    local delta = math.floor((time - player.time) * 20)
    local frame = 13 - 4
    
    -- are we moving horizontally
    local base = player.dx + player.pushdir
    if base ~= 0 then
      frame = delta % 2
    end
    
    -- vertical move?
    if player.dy < 0 then
      frame = 2 + delta % 2
    end
    if player.dy > 0 then
      frame = 0 + delta % 2
    end
    
    love.graphics.draw(player.sprites, player.quads[4 + base*4 + frame], 
                       x, y, 
                       0, 1, 1, 0, 0, 0, 0)
  else
    love.graphics.draw(player.sprites, player.quads[12], 
                       x, y, 
                       0, 1, 1, 0, 0, 0, 0)
  end  
end


player.go = go

player.load = load
player.update = update
player.draw = draw


return player
