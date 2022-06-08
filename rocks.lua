local rocks = {}


local function add(x, y, c)

  local rock = {}

  rock.x = x
  rock.y = y
  rock.dx = 0
  rock.dy = 0
  rock.xoff = 0
  rock.yoff = 0
  rock.type = c
  
  table.insert(rocks.mobs, rock)
  
  print("Added a type " .. c .. " rock, now having " .. #rocks.mobs .. " in the rocks")	
  return rock
end


local function get(x, y)
  for i, mob in ipairs(rocks.mobs) do
    if mob.x == x and mob.y == y then
      return mob
    end
  end    
end


local function remove(x, y)
  for i, rock in ipairs(rocks.mobs) do
    if rock.x == x and rock.y == y then
      table.remove(rocks.mobs, i)
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
  rocks.mobs = {}
  rocks.map = map
  rocks.time = 0
end


local function isEmptyCell(x, y, player)
  local map = rocks.map
  local cell = map.getCell(x, y)
  return cell == map.M_SPACE and (x ~= player.x or y ~= player.y)
end


local function slide(mob, delta, player)
  mob.xoff = mob.dx * delta
  mob.yoff = mob.dy * delta
end


local function move(rock, map, player, gameUi)
  local x = rock.x
  local y = rock.y
  local nx = rock.x + rock.dx
  local ny = rock.y + rock.dy
  
  -- did a moving rock hit something?
  if rock.dx ~= 0 or rock.dy ~= 0 then
    
    -- the player?
    if nx == player.x and ny == player.y then
      gameUi.explode(nx, ny, map.M_BOMBER)
      player.alive = false    
    end
    
    -- a mover?
    local mob = gameUi.swarm.get(nx, ny)
    if mob then
      gameUi.explode(nx, ny, mob.type)    
    end
    local mob = gameUi.swarm.get(x, y)
    if mob then
      gameUi.explode(x, y, mob.type)
    end
  end  

  rock.dx = 0
  rock.dy = 0
  
  -- check map at desired destination
  -- is the cell clear and player not under stationary rock?
  local cell = map.getCell(x, y+1)
  
  if isEmptyCell(x, y+1, player) then
    rock.dx = 0
    rock.dy = 1
  elseif cell == map.M_ROCK or cell == map.M_DIAMOND then
    -- instable position  
    -- check for earth left or right below
    local l = isEmptyCell(x-1, y, player)
    local ld = isEmptyCell(x-1, y+1, player)
    if l and ld then
      rock.dx = -1
      rock.dy = 0
    end
    
    local r = isEmptyCell(x+1, y, player)
    local rd = isEmptyCell(x+1, y+1, player)
    if r and rd then
      rock.dx = 1
      rock.dy = 0
    end
  end
  
end


local function update(time, dt, player, gameUi)
  rocks.delta = (time - rocks.time) * rocks.map.C_SPEED 

  -- big step time?
  if rocks.delta > 31 then	
    local map = rocks.map

    for i, rock in ipairs(rocks.mobs) do
      
      if rock.dx ~= 0 or rock.dy ~= 0 then
        -- sanity check - is cell still empty?
        if isEmptyCell(rock.x + rock.dx, rock.y + rock.dy, player) then
          map.setCell(rock.x, rock.y, map.M_SPACE)
          rock.x = rock.x + rock.dx
          rock.y = rock.y + rock.dy
          map.setCell(rock.x, rock.y, rock.type)
          
          -- check cell below, if we hit something?
          if not isEmptyCell(rock.x, rock.y + 1, player) then
            if rock.type == map.M_ROCK then
              sounds.randplay(sounds.rockfall, 1, 0.1)
            else
              sounds.randplay(sounds.gemfall, 1, 0.1)
            end
          end
        else
          print("Sanity check failed, rock must bounce back")
          rock.dx = 0
          rock.dy = 0
        end
        slide(rock, 0)
      end
      
      move(rock, map, player, gameUi)
    end
    
    rocks.time = time
    
  else
    for i, rock in ipairs(rocks.mobs) do

      if isEmptyCell(rock.x + rock.dx, rock.y + rock.dy, player) then
        if rock.dx ~= 0 or rock.dy ~= 0 then    
          slide(rock, rocks.delta, player)
        end
      else
        print("Slide sanity check failed, rock must bounce back")
        rock.dx = 0
        rock.dy = 0
        rock.xoff = 0
        rock.yoff = 0    
      end
      
      if rock.dx ~= 0 and rock.dy ~= 0 then    
        print("Illegal diagonal move for rock at " .. rock.x .. " " .. rock.y)
        print("Illegal diagonal move for rock with " .. rock.dx .. " " .. rock.dy)
      end
    end    
  end
end


local function draw(xoff, yoff)

  local sprites = rocks.map.sprites
  local quads = rocks.map.quads

  for i, mob in ipairs(rocks.mobs) do
    love.graphics.draw(sprites, quads[mob.type], 
                       mob.x*32 + mob.xoff + xoff, 
                       mob.y*32 + mob.yoff + yoff, 
                       0, 1, 1, 0, 0, 0, 0)
    
  end
end


rocks.load = load
rocks.update = update
rocks.draw = draw

rocks.add = add
rocks.get = get
rocks.remove = remove

return rocks
