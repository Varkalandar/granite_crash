sounds = require("sounds")


local map = require("map")
local gameUi = require("game_ui")
local editorUi = require("editor_ui")

-- the currently active user interface
local ui = gameUi

-- game time
local time = 0 


-- all init code goes here
function love.load()
  love.window.setVSync(1)
  love.window.setTitle("Granite Crash alpha v0.01")
  love.window.setIcon(love.image.newImageData("resources/gfx/icon.png"))

  sounds.load()
  map.load()
  gameUi.load(map)
  editorUi.load(map)
end


-- the work that has to be done before each frame can be drawn
-- dt is a float, measuring in seconds
function love.update(dt)
  time = time + dt
  
  -- print("time=" .. time)
  
  ui.update(time, dt)
end

-- draw the frame
function love.draw()
  ui.draw()


  --love.graphics.print("Hello World!", 100, 100)
  --love.graphics.print("Time elapsed: " .. time, 100, 120)
  
  --love.graphics.rectangle("line", 100-10, 100-10, 200, 80)
end


function love.wheelmoved(dx, dy)
  -- not used at the moment
end


function love.keypressed(key, scancode, isrepeat)
end


function love.keyreleased(key, scancode, isrepeat)
end

