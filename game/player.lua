player = {}
player.sound = {}
player.sound.die = love.audio.newSource("waves/player/die.wav","static")
playerTS = 0.13
playerT =0-playerTS

function player:Initialize()
    player.colision = false
    player.width = 32
    player.height = 32
    player.speed = 250
    player.velocity = 0
    player.x = math.random(1,40)
    player.y = math.random(1,18)
    player.centerX = player.x + (player.width / 2)
    player.centerY = player.y + (player.height / 2)
    player.distance = ((player.width / 2) + (player.height / 2)) / 2
end

function player:move(x,y,dt)
    oldX = player.x
    oldY = player.y

    
    if x > player.x then
        player.x = player.x + 1
    end
    if x < player.x then
        player.x = player.x - 1
    end
    if y > player.y then
        player.y = player.y + 1
    end
    if y < player.y then
        player.y = player.y - 1
    end
    
    
    if player.x < 0 or player.x > 41 then
        player.x = oldX
    end
    if player.y < 0 or player.y > 19 then
        player.y = oldY
    end
    distance = math.sqrt((player.x - oldX)^2 + (player.y - oldY)^2)
end

function player:update(dt)
    if gameState == 1 then
        -- Teclado
        if love.keyboard.isDown("up") then
            atual_action = 0
        end
        if love.keyboard.isDown("down") then
            atual_action = 2
        end
        if love.keyboard.isDown("left") then
            atual_action = 3
        end
        if love.keyboard.isDown("right") then
            atual_action = 1
        end

        -- Agente
        if atual_action ~= -1 then
            if atual_action==0 then
                player:move(player.x,player.y-1,dt)
            end
            if atual_action==1 then
                player:move(player.x+1,player.y,dt)
            end
            if atual_action==2 then
                player:move(player.x,player.y+1,dt)
            end
            if atual_action==3 then
                player:move(player.x-1,player.y,dt)
            end
        end

    elseif gameState == 2 then
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            if distanceFrom(x,y,buttons.play.dx,buttons.play.dy) < buttons.play.distance then
                gameState = 1
            end
        end
        if love.mouse.isDown(1) then
            local x = love.mouse.getX()
            local y = love.mouse.getY()
            if distanceFrom(x,y,buttons.play.dx,buttons.play.dy) < buttons.play.distance then
                gameState = 1
            end
        end
    elseif gameState == 0 then

        if love.keyboard.isDown("t") then
            gameState = 1
        end

        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            if distanceFrom(x,y,buttons.play.dx,buttons.play.dy) < buttons.play.distance then
                gameState = 1
            end
        end
        if love.mouse.isDown(1) then
            local x = love.mouse.getX()
            local y = love.mouse.getY()
            if distanceFrom(x,y,buttons.play.dx,buttons.play.dy) < buttons.play.distance then
                gameState = 1
            end
        end

    end


end

function player:increased()
    player.speed = player.speed + 3
end

return player