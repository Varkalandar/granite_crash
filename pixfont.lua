-- 
-- Bitmap font
--
-- Author: Hj. Malthaner
-- Date: 2021/04/24
--


local utf8 = require("utf8")


local pixfont = {}


local function readKerningInfo(pixfont, path)

  local file, size = love.filesystem.read(path..".kern")
  local lines = {}
  
  for line in string.gmatch(file, ".-\n") do
    -- table.insert(lines, line:match("[^\n]*"))
    -- print(line)
    
    local char = string.byte(line)
    -- check if this is kerning or slip
    if string.sub(line, 2, 2) == " " then
      -- kerning
      local adjustment = tonumber(string.sub(line, 3, -1))
      -- print("Kerning adjustment for letter " .. char .. " is " .. adjustment )
      pixfont.letterWidths[char] = pixfont.letterWidths[char] + adjustment
      
    elseif string.sub(line, 2, 2) == "-" then
      -- slip
      pixfont.slips[char] = string.sub(line, 3, -1)
      -- print("Slips for letter " .. char .. " are " .. pixfont.slips[char])
    end
  end

end


local function scanWidth(rasterX, rasterY, data, sx, sy)

  for x=rasterX-1, 0, -1 do
          
    for y=0, rasterY-1 do
      local xx = sx + x
      local yy = sy + y
              
      -- print("xx=" .. xx .. " yy=" .. yy)       
              
      local r, g, b, a = data:getPixel(xx, yy)
      -- print("a=" .. a)
      if a  > 0.5 then
        -- found a colored pixel
        return x+1
      end         
    end       
  end
  return 0
end


local function scanHeight(rasterX, rasterY, data, sx, sy)

  for y=rasterY-1, 0, -1 do
    for x=0, rasterX-1 do
          
      local xx = sx + x
      local yy = sy + y
              
      -- print("xx=" .. xx .. " yy=" .. yy)       
              
      local r, g, b, a = data:getPixel(xx, yy)
      -- print("a=" .. a)
      if a  > 0.5 then
        -- found a colored pixel
        return y+1
      end         
    end       
  end
  return 0
end


local function scanDimensions(pixfont)

  for letter=0, 255 do
    local sx = (letter % 8) * pixfont.rasterX
    local sy = math.floor(letter / 8) * pixfont.rasterY

    -- print("Sourcing " .. letter .. " from " .. sx .. ", " .. sy)
    pixfont.letterWidths[letter] = scanWidth(pixfont.rasterX, pixfont.rasterY, pixfont.imageData, sx, sy)
    -- print("Width " .. letter .. " = " .. pixfont.letterWidths[letter])
    pixfont.letterHeights[letter] = scanHeight(pixfont.rasterX, pixfont.rasterY, pixfont.imageData, sx, sy)
  
    pixfont.quads[letter] = love.graphics.newQuad(sx, sy, 
                                                  pixfont.letterWidths[letter], 
                                                  pixfont.letterHeights[letter], 
                                                  pixfont.image)
  end
end

  
local function calcStringWidth(pixfont, text)

  local letterWidths = pixfont.letterWidths
  local w = 0;
        
  for p, c in utf8.codes(text) do
    w = w + letterWidths[c]
  end     
  
  return w
end


local function drawCharacterScaled(pixfont, x, y, character, scx, scy, slx, sly)

  local quad = pixfont.quads[character]
  love.graphics.draw(pixfont.image, quad, x, y, 0, scx, scy, 0, 0, slx, sly)
end


local function drawStringScaled(pixfont, text, x, y, scx, scy, slx, sly)

  local runx = 0
  local lastc = 0
  
  for p, c in utf8.codes(text) do
    
    if p > 0 and pixfont.slips[lastc] then
      if pixfont.slips[lastc]:find(utf8.char(c)) then
        runx = runx - pixfont.rasterX / 16
      end
    end

    drawCharacterScaled(pixfont, x+runx*scx, y, c, scx, scy, slx, sly)

    runx = runx + pixfont.letterWidths[c]
    lastc = c
  end
  
  return runx * scx
end


local function drawBoxStringScaled(pixfont, text, x, y, w, h, linespace, scx, scy, slx, sly)

  local runx = 0
  local lines = 0
  local space = calcStringWidth(pixfont, " ") * scx
  text = text .. "\n"
  local words = text:gmatch("(.-)([ %.%,%!%?%;\n]+)")
  
  for word, wspace in words do
    -- print("'" .. word  .. "'<" .. wspace .. ">")
    
    word = word .. wspace
    local l = calcStringWidth(pixfont, word) * scx
    if runx + l > w then
      runx = 0
      lines = lines + 1
    end
    
    drawStringScaled(pixfont, word, runx + x, y + lines * linespace, scx, scy, slx, sly)
    
    runx = runx + l -- + space
	
  	-- test for in-string newlines?
	  for newline in wspace:gmatch("\n") do
	    runx = 0
	    lines = lines + 1
	  end

  end
  
  return lines + 1
end


local function init(path)

  print("Loading pixfont '" .. path .. "'")
  local pixfont = {}
  
  pixfont.imageData = love.image.newImageData(path .. ".png")
  pixfont.image = love.graphics.newImage(pixfont.imageData)
  
  pixfont.image:setFilter("linear", "linear", 8)
  -- pixfont.image:setFilter("nearest", "nearest")
  
  pixfont.letterWidths = {}
  pixfont.letterHeights = {}
  pixfont.quads = {}
  pixfont.slips = {}
  
  pixfont.rasterX = pixfont.image:getWidth() / 8
  pixfont.rasterY = pixfont.image:getHeight() / 32
        
  pixfont.drawStringScaled = drawStringScaled
  pixfont.drawBoxStringScaled = drawBoxStringScaled
  pixfont.calcStringWidth = calcStringWidth
  
  scanDimensions(pixfont)
  readKerningInfo(pixfont, path)
  pixfont.imageData = nil
  
  return pixfont
end


pixfont.init = init


return pixfont
