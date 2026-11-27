local background = {}

local ASSET_PATH = "assets/backgrounds/space-pixel-art.png"

local image

function background.load()
    image = love.graphics.newImage(ASSET_PATH)
    image:setFilter("nearest", "nearest")
end

function background.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(image, 0, 0)
end

return background
