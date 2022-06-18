-- 
-- "Granite Crash" animation handling
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--


local animations = {}

local function make(callback, x, y, range, params)
  local data = {}

  data.x = x
  data.y = y
  data.range = range
  data.base = 0
  data.time = 0
  data.frame = -1
  data.callback = callback
  data.params = params
  
  table.insert(animations.queue, data)
  
  return data
end


local function load()
  local image = love.graphics.newImage("resources/gfx/explosion.png")  
  local quads = {}
  local w = 32;
  
  for i=0,9 do
    quads[i] = love.graphics.newQuad(26 + i*85, 16, w, w, image)
  end
  
  animations.sprites = image
  animations.quads = quads
  animations.queue = {}
end


local function update(time, dt)
  for i=#animations.queue, 1, -1 do
    local data = animations.queue[i]
    data.time = data.time + dt
    data.frame = math.floor(data.base + data.time * 30)
    
    -- animation done?
    if data.frame > 9 then
      table.remove(animations.queue, i)
      if data.callback then
        data.callback(data.x, data.y, data.params)
      end
    end
  end
end


local function draw(xoff, yoff)

  local mode, alphamode = love.graphics.getBlendMode( )
  love.graphics.setBlendMode("add")

  for i, data in ipairs(animations.queue) do
    if data.frame >= 0 and data.frame <= 11 then
      local quad = animations.quads[data.frame]
      
      for i=-1, 1 do
        for j=-1, 1 do
          local nx = data.x*32 + xoff + i*32
          local ny = data.y*32 + yoff + j*32
      
          love.graphics.draw(animations.sprites, quad, 
                     nx, 
                     ny, 
                     0, nil, nil, 0, 0, 0, 0)
        end
      end
    end
  end

  love.graphics.setBlendMode(mode, alphamode)
end


animations.make = make
animations.load = load
animations.update = update
animations.draw = draw

return animations
