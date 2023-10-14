

function love.conf(t)
    t.window.title = "Perseguidor"
    --t.window.width = 1440
    --t.window.height = 900
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = love._os == "Android" or love._os == "iOS" or love._os == "Linux"
end