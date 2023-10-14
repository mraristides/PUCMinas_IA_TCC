database = {}
udp = socket.udp()
love.filesystem.setIdentity("perseguidor",true)
json = require "json"
address, port = "0.0.0.0", 2223
entity = "game"
atual_action = -1
save_action = -1
dataTS = 0.18
dataT =0-dataTS


function database:save(score,time)
    local saveData = {}
    saveData.score = maxScore + score
    saveData.time = math.floor(time)
    love.filesystem.write("save.lua", table.show(saveData, "saveData"))
end

function database:get()
    if love.system.getOS() == "Android" then
        if love.filesystem.exists("save.lua") then
            local load = love.filesystem.load("save.lua")
            load()
            if saveData then
                maxScore = saveData.score
                maxTime = saveData.time
            end
        end
    else
        if love.filesystem.getInfo("save.lua") then
            local load = love.filesystem.load("save.lua")
            load()
            if saveData then
                maxScore = saveData.score
                maxTime = saveData.time
            end
        end
    end
end

function database:gymsave(t, p, e, coin)
    local gymData = {}
    gymData.socket = "game"
    local seconds = math.floor(t)
    local distance = distanceFrom(e.x,e.y,p.x,p.y)
    local pw, pw_upper, pw_right, pw_bottom, pw_left = 0, 0, 0, 0, 0

    if (p.x <= 0) or (p.x >= 41) or (p.y  <= 0) or (p.y  >= 19) then
        pw = 1
        if p.x <= (0) then pw_left=1 end
        if p.x >= (41) then pw_right=1 end
        if p.y  <= (0) then pw_upper=1 end
        if p.y  >= (19) then pw_bottom=1 end
    end

    local pd_upper, pd_right, pd_bottom, pd_left, diffx, diffy = 0, 0, 0, 0, 0, 0
    if (p.y~=e.y) then
        if (p.y > e.y) then
            pd_upper=1
        else
            pd_bottom=1
        end
    end
    if (p.x~=e.x) then
        if (p.x > e.x) then
            pd_left=1
        else
            pd_right=1
        end
    end

    player_direction = { 0,0,0,0 }
    for i=1,4 do 
        if save_action==(i-1) then
            player_direction[i] = 1
        end
    end
    

    gymData.player = 
    { 
        x = p.x,
        y = p.y,
        distance = math.floor(distance),
        velocity = p.velocity,
        score = score,
        seconds = seconds,
        wall = pw,
        walls = { pw_upper, pw_right, pw_bottom, pw_left },
        dangers = { pd_upper, pd_right, pd_bottom, pd_left },
        direction = player_direction,
        colision = p.colision,
        reward = 0,
        done = false
    }


    gymData.enemy = 
    { 
        x = e.x,
        y = e.y,
        distance = math.floor(distance),
    }
    
    gymData.coins = {}
    coin_dist = math.floor(distanceFrom(coin.x,coin.y,p.x,p.y))

    local coin_dir_upper = 0
    local coin_dir_bottom = 0
    local coin_dir_left = 0
    local coin_dir_right = 0
    local diffcx, diffcy = 0, 0
    if (p.x > coin.x) then
        diffcx = p.x - coin.x
    else
        diffcx = coin.x - p.x
    end
    if (p.y > coin.y) then
        diffcy = p.y - coin.y
    else
        diffcy = coin.y - p.y
    end

    --if (diffcx > diffcy) then
    if (p.x~=coin.x) then
        if (p.x > coin.x) then
            coin_dir_left=1
        else
            coin_dir_right=1
        end
    end
    --else
    if (p.y~=coin.y) then
        if (p.y > coin.y) then
            coin_dir_upper=1
        else
            coin_dir_bottom=1
        end
    end
    --end
    table.insert(gymData.coins,{ x=coin.x,y=coin.y,has=true,distance=coin_dist,colision=coin.colision, direction = { coin_dir_upper, coin_dir_right, coin_dir_bottom, coin_dir_left } })
    table.insert(gymData.coins,{ x=0,y=0,has=false,distance=0,colision=false})

    local dir_legal, dir_coin, dir_danger = true, false, false
    for i=1,4 do 
        local dir = gymData.player.direction[i]
        if (dir==1) then
            local dir_coins = gymData.coins[1].direction[i]
            local dir_walls = gymData.player.walls[i]
            local dir_dangers = gymData.player.dangers[i]
            if (dir==dir_coins) then
                dir_legal, dir_coin = true, true
            end
            if (dir==dir_walls) then
                dir_legal = false
            end
            if (dir==dir_dangers) then
                dir_legal = false
                dir_danger = true
            end
        end
    end
        
    local reward = 0
    local sesP = {0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1}
    c_d = distance / 43
    cc_d = 1-(coin_dist / 43)
    if dir_legal then
        reward = 10
        for i=1,9 do 
            if c_d < sesP[i] then
                reward = sesP[i] * 10
            end
        end
        if dir_coin  then
            if (p.x==coin.x or p.y==coin.y) then
                reward = reward*10
                if (coin_dist<=1) then
                    reward = 200
                end
            else
                reward = reward*5
            end
        end
    else
        reward = -10
        for i=1,9 do 
            if (1-c_d) < sesP[i] then
                reward = sesP[i] * -10
            end
        end
    end

    if dir_coin and (p.x==coin.x or p.y==coin.y) then
        if (coin_dist<=1) then
            reward = 200
        end
    end

    if (p.colision) then  
        reward = -100
        gymData.player.done = true
    end

    gymData.player.reward = reward

    gymData.info = 
    {
        gamestate = gameState
    }
    local dg = json.encode(gymData)
	udp:send(dg) 
end

function database:update_agent()
    local gymData = {}
    gymData.action = -1
    gymData.restart = false
    gymData.socket = 'agent'
    local dg = json.encode(gymData)
	udp:send(dg) 
end

function database:init_socket()
    udp:settimeout(0)
    udp:setpeername(address, port)
end

function database:update(dt)
    dataT = dataT + dt
    if dataT > (dataTS) then
        repeat
            data, msg = udp:receive()
            if data then
                res = json.decode(data)
                game_state = res['game']['info']['gamestate']
                agent_restart = res['agent']['restart']
                if agent_restart then
                    --restart()
                    gameState = 1
                    database:update_agent()
                else 
                    action = res['agent']['action']
                    atual_action, save_action = action, action
                end
            elseif msg ~= 'timeout' then 
                --error("Network error: "..tostring(msg))
            end
            until not data
        dataT=dataT-(dataTS)
    end
    
end


return database