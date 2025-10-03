local player = {
    x = 100,
    y = 100,
    speed = 300,
    asset = nil,
    width = nil,
    height = nil,
}
local gravity = 800 

function love.load()
    player.asset = love.graphics.newImage("assets/player.png")
    player.width = player.asset:getWidth()
    player.height = player.asset:getHeight()

    player.vy = 0
    player.scale = 0.05
    groundY = love.graphics.getHeight() - 40
    rightWall = love.graphics.getWidth() - 20
end

-- function love.update(dt)
--     player.vy = player.vy + gravity * dt
--     player.y = player.y + player.vy * dt

--     if player.y + player.height * player.scale > groundY then
--         player.y = groundY - player.height * player.scale
--         player.vy = 0
--     end
-- end

function love.update(dt)
    player.vy = player.vy + gravity * dt
    player.y = player.y + player.vy * dt

    if player.y + player.height * player.scale > groundY then
        player.y = groundY - player.height * player.scale
        player.vy = 0
    end
end

function love.keypressed(key)
    if key == "space" then
        player.vy = -300
    end
    -- if key == "x" then 
    --     plyer.x = 300
    -- end
end

-- function love.update(dt)
--     if love.keyboard.isDown("d") then
--         player.x = player.x + player.speed * dt
--     elseif love.keyboard.isDown("a") then
--         player.x = player.x - player.speed * dt
--     end
--     if love.keyboard.isDown("s") then
--         player.y = player.y + player.speed * dt
--     elseif love.keyboard.isDown("w") then
--         player.y = player.y - player.speed * dt
--     end
-- end


function love.draw()
    love.graphics.setColor(0.2, 0.7, 0.2)
    love.graphics.rectangle("fill", 0, groundY, love.graphics.getWidth(), love.graphics.getHeight() - groundY)

    love.graphics.setColor(1,1,1)

    love.graphics.draw(player.asset, player.x, player.y, 0, player.scale, player.scale)
end