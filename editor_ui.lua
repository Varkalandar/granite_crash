-- 
-- "Granite Crash" map editor
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

local editorUi = {}


local function load(map)
  editorUi.map = map
end


local function update(time, dt)
end


local function draw()
end


local function mousePressed(button, mx, my)
end


local function mouseReleased(button, mx, my)
end


local function mouseDragged(button, mx, my)
end


local function keyReleased(key, scancode, isrepeat)
end


editorUi.load = load
editorUi.update = update
editorUi.draw = draw

editorUi.mousePressed = mousePressed
editorUi.mouseReleased = mouseReleased
editorUi.mouseDragged = mouseDragged
editorUi.keyReleased = keyReleased


return editorUi
