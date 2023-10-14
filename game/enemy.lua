enemy = {}
enemyTS = 0.33
enemyT =0-enemyTS

function enemy:Initialize()
    enemyT =0-enemyTS
    count_enemy_reset = 0.01
    count_enemy = count_enemy_reset
    count_transform_reset = 1.1
    count_transform = count_transform_reset
    enemy.width = 32
    enemy.height = 32
    while true do
        local random_x =  math.random(0,41) 
        local random_y =  math.random(0,19)
        local distance_from_player = distanceFrom(random_x,random_y,player.centerX,player.centerY)
        if (distance_from_player > 15) then
            enemy.x = random_x
            enemy.y = random_y
            break
        end
    end
    enemy.speed = 150
    enemy.enemy_transform = false
    enemy.centerX = enemy.x + (enemy.width / 2)
    enemy.centerY = enemy.y + (enemy.height / 2)
    enemy.distance = ((enemy.width / 2) + (enemy.height / 2)) / 2
end


function enemy:increased()
    enemy.speed = enemy.speed + 3
end
function enemy:update(dt)
    
    if gameState == 1 then
        enemyT = enemyT + dt
        
        --if enemy.enemy_transform == true then
        --    if count_transform <= 0 then
                --enemy:transform(false)
        --        count_transform = count_transform_reset
        --    end
        --    count_transform = count_transform - dt
        --end

        if enemyT > (enemyTS) then
            local dx, dy = (enemy.x-player.x), (enemy.y-player.y)
            if (dx<0) then
                dx = dx *-1
            end
            if (dy<0) then
                dy = dy *-1
            end
            if (dx >= dy) then
                if (enemy.x < player.x) then
                    enemy.x = (enemy.x + 1)
                end
                if (enemy.x > player.x) then
                    enemy.x = (enemy.x - 1)
                end
            else
                if (enemy.y < player.y) then
                    enemy.y = (enemy.y + 1)
                end
                if (enemy.y > player.y) then
                    enemy.y = (enemy.y - 1)
                end
            end
            enemyT=enemyT-(enemyTS)
        end

        if distanceFrom(enemy.x,enemy.y,player.x,player.y) <= 0 then
            player.sound.die:play()
            ads:show()
            if time >= maxTime then
                database:save(score,time)
            else
                database:save(score,maxTime)
            end
            player.colision = true
        end
        
    end
end

return enemy