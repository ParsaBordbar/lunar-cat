local colors

local function drawRockWall(e)
    love.graphics.setColor(colors.wall)
    love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)
    love.graphics.setColor(colors.crater)
    for _, s in ipairs(e.spots) do
        love.graphics.circle("fill", e.x + s.x, e.y + s.y, s.r)
    end
    love.graphics.setColor(colors.wallEdge)
    local edgeY = e.ceiling and (e.y + e.h - 6) or e.y
    love.graphics.rectangle("fill", e.x, edgeY, e.w, 6)
end

local function drawBulkhead(e)
    love.graphics.setColor(colors.bulkhead)
    love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)

    love.graphics.setColor(colors.bulkheadLine)
    love.graphics.setLineWidth(2)
    for y = e.y + 28, e.y + e.h - 12, 28 do
        love.graphics.line(e.x + 4, y, e.x + e.w - 4, y)
    end
    love.graphics.setColor(colors.deckEdge)
    for _, cx in ipairs({ e.x + 6, e.x + e.w - 10 }) do
        love.graphics.rectangle("fill", cx, e.y + 6, 4, 4)
        love.graphics.rectangle("fill", cx, e.y + e.h - 10, 4, 4)
    end

    local stripeY = e.ceiling and (e.y + e.h - 10) or e.y
    local block = 14
    for i = 0, math.ceil(e.w / block) - 1 do
        local left = e.x + i * block
        love.graphics.setColor(i % 2 == 0 and colors.hazardYellow or colors.hazardBlack)
        love.graphics.rectangle("fill", left, stripeY, math.min(block, e.x + e.w - left), 10)
    end
end

local function drawWall(e)
    if e.zone == "station" then drawBulkhead(e) else drawRockWall(e) end
    love.graphics.setColor(colors.outline)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", e.x, e.y, e.w, e.h)
end

local function drawSpikes(e, clock)
    if e.zone == "station" then
        local flicker = 0.75 + 0.25 * math.sin(clock * 20 + e.x * 0.1)
        love.graphics.setColor(1, 0.6 + 0.3 * flicker, 0.2, flicker)
    else
        love.graphics.setColor(colors.crystal)
    end
    local count = math.max(1, math.floor(e.w / 20))
    local sw = e.w / count
    for i = 0, count - 1 do
        local x0 = e.x + i * sw
        if e.ceiling then
            love.graphics.polygon("fill", x0, e.y, x0 + sw, e.y, x0 + sw / 2, e.y + e.h)
        else
            love.graphics.polygon("fill", x0, e.y + e.h, x0 + sw, e.y + e.h, x0 + sw / 2, e.y)
        end
    end
    if e.zone == "station" then
        love.graphics.setColor(colors.hazardBlack)
        local baseY = e.ceiling and e.y or (e.y + e.h - 5)
        love.graphics.rectangle("fill", e.x - 4, baseY, e.w + 8, 5)
    end
end

local function drawTrail(e)
    local t = colors.trail
    for k = 1, 5 do
        love.graphics.setColor(t[1], t[2], t[3], 0.5 - k * 0.09)
        love.graphics.circle("fill",
            e.x - e.trailVX * k * 0.025, e.y - e.trailVY * k * 0.025, e.r * (1 - k * 0.15))
    end
end

local function drawMeteor(e)
    drawTrail(e)
    love.graphics.setColor(colors.meteor)
    love.graphics.circle("fill", e.x, e.y, e.r)
    love.graphics.setColor(colors.meteorCrater)
    for k = 0, 2 do
        local a = e.angle + k * 2.1
        love.graphics.circle("fill", e.x + math.cos(a) * e.r * 0.45, e.y + math.sin(a) * e.r * 0.45, e.r * 0.22)
    end
end

local function drawDebris(e)
    drawTrail(e)
    local s = e.r * 0.8
    love.graphics.push()
    love.graphics.translate(e.x, e.y)
    love.graphics.rotate(e.angle)
    love.graphics.setColor(colors.debris)
    love.graphics.rectangle("fill", -s, -s, s * 2, s * 2)
    love.graphics.setColor(colors.debrisStripe)
    love.graphics.rectangle("fill", -s, -s * 0.25, s * 2, s * 0.5)
    love.graphics.setColor(colors.outline)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -s, -s, s * 2, s * 2)
    love.graphics.pop()
end

local function drawFish(e)
    local cx = e.x + e.w / 2
    local cy = e.y + e.h / 2 + math.sin(e.bob) * 4
    love.graphics.setColor(colors.fish)
    love.graphics.polygon("fill", cx - 12, cy, cx - 22, cy - 9, cx - 22, cy + 9)
    love.graphics.polygon("fill", cx - 14, cy, cx, cy - 10, cx + 16, cy, cx, cy + 10)
    love.graphics.setColor(0.15, 0.1, 0.1)
    love.graphics.circle("fill", cx + 7, cy - 2, 2)
end

return function(c)
    colors = c
    return {
        drawWall = drawWall,
        drawSpikes = drawSpikes,
        drawMeteor = drawMeteor,
        drawDebris = drawDebris,
        drawFish = drawFish,
    }
end
