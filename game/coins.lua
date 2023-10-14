coins = {}
all_coins = {}

function coins:Initialize()
    if table.maxn(all_coins) > 0 then
        for i,c in ipairs(all_coins) do
            table.remove(all_coins,i)     
        end
    end
    coins:spawn()
    --count_coin_reset = 5
    --count_coin = count_coin_reset
end

function coins:spawn() 
    local coin = {}
    coin.sprite = love.graphics.newImage("sprites/coin/coin.png")
    coin.sound = love.audio.newSource("waves/coin/coin.wav","static")
    local x = math.random(0,41)
    local y = math.random(0,19)
    coin.x = x
    coin.y = y
    coin.colision = false
    coin.centerX = coin.x + 20
    coin.centerY = coin.y + 20 
    coin.distance = ((coin.sprite:getWidth() / 2) + (coin.sprite:getHeight() / 2)) / 4
    coin.remove = 10
    coin.frame = {}
    coin.frame.grid = anim8.newGrid(20,21, coin.sprite:getWidth(), coin.sprite:getHeight())
    coin.frame.animation = anim8.newAnimation(coin.frame.grid('1-3',1,'1-3',2,'1-2',3), 0.05)
    table.insert(all_coins,coin)
end

function coins:update(dt)
    if table.maxn(all_coins) > 0 then
        for i,c in ipairs(all_coins) do
            c.frame.animation:update(dt)
            if distanceFrom(player.x,player.y,c.x,c.y) <= 0 then
                c.colision = true
                c.sound:play()
                score = score + 1
            end
        end
    end
end

function coins:increased()
    count_coin_reset = count_coin_reset - 0.01
end

return coins