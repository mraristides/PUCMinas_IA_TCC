settings = {}
settings.interface = {}
settings.game = {}
settings.audios = {}


function settings:Initialize()
  gameState = 0
  score = 0
  maxScore = 0
  time = 0
  maxTime = 0
  database:get()
  settings.interface:Initialize()
  
  for i=1,1,1 do
    local audio = love.audio.newSource("waves/game/game"..i..".wav","stream")
    audio:setLooping(true)
    table.insert(settings.audios, audio)
  end

  settings.audios[1]:play()
end

function settings.interface:Initialize()

  love.window.setMode(0,0,{fullscreen=true})
  local width, height, flags = love.window.getMode()
  settings.interface.width = width
  settings.interface.height = height
  
  settings.interface.top = {
    x = 0,
    y = 0,
    width = settings.interface.width,
    height = 110,
  }
  settings.interface.rightbottom = {
    x = settings.interface.width - 350,
    y = settings.interface.height - 350,
    width = 300,
    height = 300
  }
end

function settings.interface:draw()
    love.graphics.rectangle("line",settings.interface.top.x,settings.interface.top.y,settings.interface.top.width,settings.interface.top.height)
    love.graphics.rectangle("line",settings.interface.rightbottom.x+50,settings.interface.rightbottom.y+50,settings.interface.rightbottom.width,settings.interface.rightbottom.height)
end

function settings:update(dt)
end

settings:Initialize()
return settings


