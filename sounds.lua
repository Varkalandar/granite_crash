-- 
-- Game sounds
--
-- Author: Hj. Malthaner
-- Date: 2022/06/06
--


local sounds = {}


local function load()

  local walkData = love.sound.newSoundData("resources/sfx/walk.wav")  
  sounds.walk = love.audio.newSource(walkData)
  sounds.walk:setVolume(0.5)

  local bangData = love.sound.newSoundData("resources/sfx/bang.wav")  
  sounds.bang = love.audio.newSource(bangData)
  sounds.bang:setVolume(1.0)

  local collectData = love.sound.newSoundData("resources/sfx/collect.wav")  
  sounds.pick = love.audio.newSource(collectData)
  sounds.pick:setVolume(1.0)

  local rockfallData = love.sound.newSoundData("resources/sfx/rockfall.wav")  
  sounds.rockfall = love.audio.newSource(rockfallData)
  sounds.rockfall:setVolume(1.0)

  local gemfallData = love.sound.newSoundData("resources/sfx/gemfall.wav")  
  sounds.gemfall = love.audio.newSource(gemfallData)
  sounds.gemfall:setVolume(1.0)

end


local function randplay(source, pitch, rand)
  source:stop()
  source:setPitch(pitch - rand + math.random() * 2.0 * rand)
  source:play()
end


sounds.load = load
sounds.randplay = randplay


return sounds
