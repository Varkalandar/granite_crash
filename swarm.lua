-- 
-- "Granite Crash" critter swarm handling
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local swarm = {}


local function add(x, y, c)

  local mover = {}

  mover.x = x
  mover.y = y
  mover.dx = -1
  mover.dy = 0
  mover.xoff = -31
  mover.yoff = 0
  mover.type = c
  mover.time = 0
  
  table.insert(swarm.mobs, mover)
  
  print("Added a type " .. c .. " mover, now having " .. #swarm.mobs .. " in the swarm")	
  return mover
end


local function get(x, y)
  for i, mob in ipairs(swarm.mobs) do
    if mob.x == x and mob.y == y then
      return mob
    end
  end    
end


local function remove(x, y)
  for i, mob in ipairs(swarm.mobs) do
    if mob.x == x and mob.y == y then
      table.remove(swarm.mobs, i)
    end
  end    
end


local function collisions(map, player, gameUi)

  for i, mob in ipairs(swarm.mobs) do
    if mob.x == player.x and mob.y == player.y then      
      player.alive = false
      gameUi.explode(mob.x, mob.y, mob.type)
    end
  end
end


local function turn_right(dx, dy)
  return -dy, dx
end


local function turn_left(dx, dy)
  return dy, -dx
end



local function load(map)
  swarm.mobs = {}
  swarm.map = map
  swarm.time = 0
end


local function slide(mob, delta)
  mob.xoff = mob.dx * (delta - 32)
  mob.yoff = mob.dy * (delta - 32)
end


local function move(mob, map)

  local dx = mob.dx
  local dy = mob.dy 

  if mob.type == map.M_BOMBER then
    dx, dy = turn_right(dx, dy)
  else
    dx, dy = turn_left(dx, dy)
  end

  for i=1, 4 do
    -- print("turn " .. i .. " dx=" .. dx  .. " dy=" .. dy)

    local nx = mob.x+dx
    local ny = mob.y+dy
    local cell = map.getCell(nx, ny)
    
    -- print("turn " .. i .. " x=" .. nx  .. " y=" .. ny .. " cell=" .. cell)
    
    -- check map at desired destination
    if cell == map.M_SPACE or
       cell == map.M_BLOCKER then
      mob.x = nx
      mob.y = ny
      mob.dx = dx
      mob.dy = dy
      slide(mob, 0)
      break
    else
      if mob.type == map.M_BOMBER then
        dx, dy = turn_left(dx, dy)
      else
        dx, dy = turn_right(dx, dy)
      end
    end
  end
end


local function update(time, dt, speed)
  swarm.delta = (time - swarm.time) * speed 

  -- big step time?
  if swarm.delta > 31 then	
    local map = swarm.map

    for i, mob in ipairs(swarm.mobs) do
      move(mob, map)
    end
    
    swarm.time = time
    
  else
    for i, mob in ipairs(swarm.mobs) do
      slide(mob, swarm.delta)
    end    
  end
end


local function draw(xoff, yoff)

  local sprites = swarm.map.sprites
  local quads = swarm.map.quads

  local size = 0.5 + (1.0 + math.sin(swarm.time * swarm.map.C_SPEED * 2 * math.pi)) * 0.25
  local soff = math.floor((32.0 - size*32.0) * 0.5)
  for i, mob in ipairs(swarm.mobs) do
    love.graphics.draw(sprites, quads[mob.type], 
                       mob.x*32 + mob.xoff + xoff + soff, 
                       mob.y*32 + mob.yoff + yoff + soff, 
                       0, size, size, 0, 0, 0, 0)
    
  end
end


swarm.load = load
swarm.update = update
swarm.draw = draw

swarm.add = add
swarm.get = get
swarm.remove = remove
swarm.collisions = collisions

return swarm
