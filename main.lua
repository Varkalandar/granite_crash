-- 
-- "Granite Crash" startup file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--

sounds = require("sounds")


local map = require("map")
local gameUi = require("game_ui")
local editorUi = require("editor_ui")
local titleUi = require("title_ui")


-- the currently active user interface
local ui = titleUi

-- game time
local time = 0 


local function switchToEditor()
  editorUi.load(map)
  ui = editorUi
end


local function switchToGame()
  ui = gameUi
end


-- all init code goes here
function love.load()
  love.window.setVSync(1)
  love.window.setTitle("Granite Crash alpha v0.05")
  love.window.setIcon(love.image.newImageData("resources/gfx/icon.png"))

  sounds.load()
  map.load()
  gameUi.load(map)
  titleUi.load(switchToGame)
end


-- the work that has to be done before each frame can be drawn
-- dt is a float, measuring in seconds
function love.update(dt)
  time = time + dt 
  ui.update(time, dt)
end


-- draw the frame
function love.draw()
  ui.draw()
end




function love.wheelmoved(dx, dy)
end


function love.mousepressed(mx, my, b)
  ui.mousePressed(b, mx, my)
end


function love.mousereleased(mx, my, b)
  ui.mouseReleased(b, mx, my)
end


function love.keypressed(key, scancode, isrepeat)
  ui.keyPressed(key, scancode, isrepeat)
end


function love.keyreleased(key, scancode, isrepeat)
  if key == "e" then
    switchToEditor()
  end
  
  ui.keyReleased(key, scancode, isrepeat)
end

