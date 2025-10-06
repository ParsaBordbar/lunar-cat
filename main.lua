local player = {
    x = 100,
    y = 700,
    speed = 300,
    width = nil,
    height = nil,
    spriteSheets = {
        idle = nil,
        jump = nil
    },
    animation = {
        idle = nil,
        jump = nil
    }
}
local gravity = 900 

local background = {
    layer1 = nil,
    layer2 = nil,
    layer3 = nil,
    layer4 = nil,
    layer5 = nil,
    layer6 = nil,
    layer7 = nil,
    layer8 = nil,
    layer9 = nil,
    layer10 = nil,
    layer11 = nil,
}

local layers = {
  "Layer_0000_9.png",
  "Layer_0001_8.png",
  "Layer_0002_7.png",
  "Layer_0003_6.png",
  "Layer_0004_Lights.png",
  "Layer_0005_5.png",
  "Layer_0006_4.png",
  "Layer_0007_Lights.png",
  "Layer_0008_3.png",
  "Layer_0009_2.png",
  "Layer_0010_1.png",
  "Layer_0011_0.png"
}


function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    player.spriteSheets.idle = love.graphics.newImage("assets/player/IdleCat.png")
    player.width = player.spriteSheets.idle:getWidth()
    player.height = player.spriteSheets.idle:getHeight()

    player.spriteSheet2 = love.graphics.newImage("assets/player/JumpCat.png")
    player.width = player.spriteSheet2:getWidth()
    player.height = player.spriteSheet2:getHeight()

    local g = anim8.newGrid(32, 32,
        player.spriteSheets.idle:getWidth(),
        player.spriteSheets.idle:getHeight()
    )

    player.anim = anim8.newAnimation(g('1-7', 1), 0.1)
    player.vy = 0
    player.scale = 0.05

    player.anim = anim8.newAnimation(g('1-7', 1), 0.1)

    groundY = love.graphics.getHeight()
    rightWall = love.graphics.getWidth()
    for i, filename in ipairs(layers) do
        background["layer"..i] = love.graphics.newImage("assets/backgrounds/" .. filename)
    end
    love.window.setMode(920, 720)
end


function love.update(dt)
    -- Graviry
    player.vy = player.vy + gravity * dt
    player.y = player.y + player.vy * dt

    -- ground collision
    if player.y + player.height * player.scale > groundY then
        player.y = groundY - player.height * player.scale
        player.vy = 0
    end
    

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    elseif love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("space") then
        local jumpCount = 2
        print(jumpCount)
        if player.y + player.height * player.scale < groundY or jumpCount == 0 then
            return
        end
        player.vy = -600
        jumpCount = jumpCount - 1
        print(jumpCount)
    end
    player.anim:update(dt)
end


function love.draw()
    for i = 11, 1, -1 do
        love.graphics.draw(background["layer"..i], 0, 0)
    end
    -- love.graphics.rectangle("fill", 0, groundY, love.graphics.getWidth(), love.graphics.getHeight() - groundY)
    player.anim:draw(player.spriteSheets.idle, player.x, player.y, 0, 2, 2)
end