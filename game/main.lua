function love.load()
    require('show')
    socket = require("socket")
    database = require("database")
    settings = require("settings")
    components = require("components")
    anim8 = require('anim8-master/anim8')
    ads = require('ads')
    player = require("player")
    enemy = require("enemy")
    coins = require('coins')
    database:init_socket()
    restart()
    gameState=1
end


function love.update(dt)
    database:update(dt)
    ads:update(dt)
    player:update(dt)
    coins:update(dt)
    settings:update(dt)
    enemy:update(dt)

    if gameState == 1 then
        database:gymsave(time,player,enemy,all_coins[1])
        if (all_coins[1].colision) then
            table.remove(all_coins,1)
            coins:spawn()
        end
        if (player.colision) then
            restart()
        end
        atual_action=-1
        time = time + dt
    end
end                                                     


function love.draw()
    love.graphics.draw(background.sprite,background.x,background.y)
    components:draw()
end

function restart()
    gameState = 0
    score = 0
    time = 0
    player:Initialize()
    enemy:Initialize()
    coins:Initialize()
    database:get()
end

-- Helpers
function distanceFrom(x1,y1,x2,y2) 
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) 
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end