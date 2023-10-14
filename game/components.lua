components = {}
sprites = {}

function components:Initialize()
    components:InitializeBackground()
    components:InitializeWindows()
    components:InitializeContentsText()
    components:InitializeButtons()
end

function components:InitializeBackground()
    background = {}
    
    background.sprite = love.graphics.newImage("sprites/background.jpg")
    background.x = 0
    background.y = 0
end

function components:InitializeWindows()
    windows = {}

    windows.game = {}
    windows.game.sprite = love.graphics.newImage("sprites/windows/game.png")
    windows.game.x = (settings.interface.width / 2) - (windows.game.sprite:getWidth()/2)
    windows.game.y = (settings.interface.height / 2) - (windows.game.sprite:getHeight()/2)
end



function components:InitializeContentsText()
    contents_text = {}

    contents_text.money = {}
    contents_text.money.sprite = love.graphics.newImage("sprites/content_text/money.png")
    contents_text.money.x = 10
    contents_text.money.y = 10
    contents_text.money.textX = (contents_text.money.sprite:getWidth() / 2) - 50
    contents_text.money.textY = (contents_text.money.sprite:getHeight() / 2) - (contents_text.money.sprite:getHeight() / 4) + 5
   

    contents_text.time = {}
    contents_text.time.sprite = love.graphics.newImage("sprites/content_text/time.png")
    contents_text.time.x = (contents_text.money.sprite:getWidth() + contents_text.money.x) + 10
    contents_text.time.y = 10
    contents_text.time.textX = ((contents_text.money.sprite:getWidth() / 2) - 55) + contents_text.time.x
    contents_text.time.textY = (contents_text.money.sprite:getHeight() / 2) - (contents_text.money.sprite:getHeight() / 4) + 5


    contents_text.maxScore = {}
    contents_text.maxScore.x = windows.game.x + 125
    contents_text.maxScore.y = windows.game.y + 190

    contents_text.maxTime = {}
    contents_text.maxTime.x = windows.game.x + 125
    contents_text.maxTime.y = windows.game.y + 100
    
end


function components:InitializeButtons()
    buttons = {}

     buttons.play = {}
     buttons.play.width = 221
     buttons.play.height = 93
     buttons.play.x = windows.game.x + 70
     buttons.play.y = windows.game.y + 363
     buttons.play.dx = buttons.play.x + (buttons.play.width  / 2)
     buttons.play.dy = buttons.play.y + (buttons.play.height / 2)
     buttons.play.distance = ((buttons.play.width  / 2) + (buttons.play.height / 2)) / 2

     buttons.pause = {}
     buttons.pause.sprite = love.graphics.newImage("sprites/buttons/pause.png")
     buttons.pause.sprite_click = love.graphics.newImage("sprites/buttons/pause_click.png")
     buttons.pause.x = (settings.interface.width - buttons.pause.sprite:getWidth())
     buttons.pause.y = 10
     buttons.pause.dx = buttons.pause.x + (buttons.pause.sprite:getWidth()  / 2)
     buttons.pause.dy = buttons.pause.y + (buttons.pause.sprite:getHeight() / 2)
     buttons.pause.distance = ((buttons.pause.sprite:getWidth()  / 2) + (buttons.pause.sprite:getHeight() / 2)) / 2
end


function components:drawClick(x,y)
    if distanceFrom(x,y,buttons.pause.dx,buttons.pause.dy) < buttons.pause.distance then
        love.graphics.draw(buttons.pause.sprite_click,buttons.pause.x,buttons.pause.y,nil)
    else
        love.graphics.draw(buttons.pause.sprite,buttons.pause.x,buttons.pause.y,nil)
    end

end





function components:draw()
    if gameState == 1 or gameState == 2 then
        if love.system.getOS() == "Android" then
            local touches = love.touch.getTouches()
            if #touches > 0 then
                for i, id in ipairs(touches) do
                    local x, y = love.touch.getPosition(id)
                    components:drawClick(x,y)
                end
            else
                love.graphics.draw(buttons.pause.sprite,buttons.pause.x,buttons.pause.y,nil)
            end
        else
            if love.mouse.isDown(1) then
                local x = love.mouse.getX()
                local y = love.mouse.getY()
                components:drawClick(x,y)
            else
                love.graphics.draw(buttons.pause.sprite,buttons.pause.x,buttons.pause.y,nil)
            end
        end


        love.graphics.draw(contents_text.money.sprite,contents_text.money.x,contents_text.money.y,nil)
        love.graphics.draw(contents_text.time.sprite,contents_text.time.x,contents_text.time.y,nil)

        love.graphics.setNewFont(39)
        love.graphics.setColor(0,0,0)
        love.graphics.print(score,contents_text.money.textX,contents_text.money.textY)
        love.graphics.print(SecondsToClock(time),contents_text.time.textX,contents_text.time.textY)
        love.graphics.setColor(255,255,255)
        love.graphics.setNewFont(12)


        local tileSize = 32  -- Define o tamanho de cada célula no cenário
        for x = 0, 41 do
            for y = 0, 19 do

                -- grid
                local tileX = 8+(x * tileSize)
                local tileY = 120+(y * tileSize)
                --love.graphics.rectangle("line", tileX, tileY, tileSize, tileSize)
                
                -- player
                local tileXPlayer = 8+(player.x * tileSize)
                local tileYPlayer = 120+(player.y * tileSize)
                love.graphics.setColor(255,255,255)
                love.graphics.rectangle("fill",tileXPlayer,tileYPlayer,player.width,player.height)

                -- enemy
                local tileXEnemy = 8+(enemy.x * tileSize)
                local tileYEnemy = 120+(enemy.y * tileSize)
                love.graphics.setColor(255,0,0)
                love.graphics.rectangle("fill",tileXEnemy,tileYEnemy,enemy.width,enemy.height)
                love.graphics.setColor(255,255,255)

                if table.maxn(all_coins) > 0 then
                    for i,c in ipairs(all_coins) do
                        local tileXC = 14+(c.x * tileSize)
                        local tileYC = 126+(c.y * tileSize)
                        c.frame.animation:draw(c.sprite, tileXC, tileYC)
                    end
                end
            end
        end

        if gameState == 2 then
            love.graphics.draw(windows.game.sprite,windows.game.x,windows.game.y,nil)
            love.graphics.setNewFont(34)
            love.graphics.setColor(0,0,0)
            love.graphics.print(maxScore,contents_text.maxScore.x,contents_text.maxScore.y)
            love.graphics.print(SecondsToClock(maxTime),contents_text.maxTime.x,contents_text.maxTime.y)
            love.graphics.setColor(255,255,255)
            love.graphics.setNewFont(12)
        end
        
    else
        love.graphics.draw(windows.game.sprite,windows.game.x,windows.game.y,nil)
        love.graphics.setNewFont(34)
        love.graphics.setColor(0,0,0)
        love.graphics.print(maxScore,contents_text.maxScore.x,contents_text.maxScore.y)
        love.graphics.print(SecondsToClock(maxTime),contents_text.maxTime.x,contents_text.maxTime.y)
        love.graphics.setColor(255,255,255)
        love.graphics.setNewFont(12)
    end


    
end




components:Initialize()


return components