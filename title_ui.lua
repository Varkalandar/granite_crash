-- 
-- "Granite Crash" title screen
--
-- Author: Hj. Malthaner
-- Date: 2022/06/17
--

local titleUi = {}


local function load(callback)
  titleUi.callback = callback
  titleUi.image = love.graphics.newImage("resources/gfx/title.png")  
  titleUi.startGame = false
end


local function update(time, dt)
end


local function draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(titleUi.image, 0, 5)

  if titleUi.startGame then
    titleUi.callback()  
  end
end


local function mousePressed(button, mx, my)
end


local function mouseReleased(button, mx, my)
end


local function mouseDragged(button, mx, my)
end


local function keyPressed(key, scancode, isrepeat)
end


local function keyReleased(key, scancode, isrepeat)
  titleUi.startGame = true
end


titleUi.load = load
titleUi.update = update
titleUi.draw = draw

titleUi.mousePressed = mousePressed
titleUi.mouseReleased = mouseReleased
titleUi.mouseDragged = mouseDragged
titleUi.keyPressed = keyPressed
titleUi.keyReleased = keyReleased


return titleUi

