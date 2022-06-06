local player = {}


local function go(time, dx, dy)
  player.dx = dx
  player.dy = dy
  player.xoff = 0
  player.yoff = 0
  player.time = time  
end


local function load(map)
  -- player images

  local image = love.graphics.newImage("resources/gfx/player.png")  
  local quads = {}
  local w = 32;
  
  -- alive
  quads[0] = love.graphics.newQuad(1*w, 0*w, w, w, 12*w, 2*w)
  
  -- dead
  quads[8] = love.graphics.newQuad(0*w, 0*w, w, w, 12*w, 2*w)
  
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
  
  player.diamonds =
  {
    required = 40,
	  collected = 0
  }
  
  player.map = map
end


local function collect()
  local map = player.map
  local cell = map.getCell(player.x, player.y)   

  if cell == map.M_DIAMOND then
    sounds.randplay(sounds.pick, 1, 0.2)
    local diamonds = player.diamonds
    diamonds.collected = diamonds.collected + 1
  
  elseif cell == map.M_EARTH then
    sounds.randplay(sounds.walk, 1, 0.2)
  end

  map.setCell(player.x, player.y, map.M_SPACE)
end


local function update(time, dt, speed)
  local delta = (time - player.time) * speed 

  -- move finished?  
  if delta > 31 then	
    player.x = player.x + player.dx
    player.y = player.y + player.dy
    player.dx = 0
    player.dy = 0  
    player.xoff = 0
    player.yoff = 0
    player.time = 0
	
	  collect()
	
  else  
    player.xoff = player.dx * delta
    player.yoff = player.dy * delta
  end
end


local function draw(x, y)
  if player.alive then
    love.graphics.draw(player.sprites, player.quads[0], 
                       x, y, 
                       0, 1, 1, 0, 0, 0, 0)
  else
    love.graphics.draw(player.sprites, player.quads[8], 
                       x, y, 
                       0, 1, 1, 0, 0, 0, 0)
  end  
end


player.go = go

player.load = load
player.update = update
player.draw = draw


return player
