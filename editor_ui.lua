-- 
-- "Granite Crash" map editor
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local editorUi = {}


local function load(map)
  editorUi.map = map
  editorUi.celltype = map.M_SPACE
  editorUi.mx = 0
  editorUi.my = 0
  editorUi.mapx = 0  -- map display x offset
  editorUi.mapy = 0  -- map display y offset
  editorUi.dragx = 0
  editorUi.dragy = 0
  editorUi.dragw = 0
  editorUi.dragh = 0
end


local function update(time, dt)

  editorUi.mx, editorUi.my = love.mouse.getPosition()

  if love.mouse.isDown(1) then
    -- plot with right mouse button
    local cx = math.floor((editorUi.mapx + editorUi.mx) / editorUi.map.raster) 
    local cy = math.floor((editorUi.mapy + editorUi.my) / editorUi.map.raster) 
    
    -- print("mapx=" .. editorUi.mapx .. " mx=" .. editorUi.mx .. " cx=" .. cx)
    
    editorUi.map.setCell(cx, cy, editorUi.celltype)
  
  elseif love.mouse.isDown(2) then  
    -- update drag distance
    editorUi.dragw = editorUi.mx - editorUi.dragx
    editorUi.dragh = editorUi.my - editorUi.dragy
  end

end


local function draw()
  local xoff = editorUi.mapx + editorUi.dragw
  local yoff = editorUi.mapy + editorUi.dragh

  love.graphics.setColor(0.9, 0.9, 0.9, 1)

  editorUi.map.drawFull(xoff, yoff)
end


local function mousePressed(button, mx, my)
  print("Mouse pressed " .. button)

  if button == 2 then
    -- drag with right mouse button
    editorUi.dragx = mx
    editorUi.dragy = my
  end
end


local function mouseReleased(button, mx, my)
  print("Mouse released " .. button)

  -- did we have a dragging event? if not, this was a click
  if editorUi.dragx == 0 or editorUi.dragy == 0 then
    -- handle a click
  end
  


  editorUi.mapx = editorUi.mapx + editorUi.dragw
  editorUi.mapy = editorUi.mapy + editorUi.dragh
  
  editorUi.dragx = 0
  editorUi.dragy = 0
  editorUi.dragw = 0
  editorUi.dragh = 0
end


local function mouseDragged(button, mx, my)
end


local function saveMap()
  local data = editorUi.map.bytes:getString( )

  local handle = assert(io.open("/tmp/map.txt", "w"))  
  handle:write(data)
  handle:close()
end


local function keyReleased(key, scancode, isrepeat)
  print("key=" .. key)

  local map = editorUi.map
  local celltype = map.M_SPACE
  if(key == "x") then
    celltype = map.M_DIAMOND
  elseif(key == "o") then
    celltype = map.M_ROCK
  elseif(key == "0") then
    celltype = map.M_WALL
  elseif(key == "e") then
    celltype = map.M_EARTH
  elseif(key == "w") then
    celltype = map.M_BOMBER
  elseif(key == "r") then
    celltype = map.M_REWARD
  end

  editorUi.celltype = celltype
  print("Setting cell type to: " .. editorUi.celltype)



  if(key == "s") then
    saveMap()
  end
end


editorUi.load = load
editorUi.update = update
editorUi.draw = draw

editorUi.mousePressed = mousePressed
editorUi.mouseReleased = mouseReleased
editorUi.mouseDragged = mouseDragged
editorUi.keyReleased = keyReleased


return editorUi
