local World = {}
World.__index = World

local SPIKE_HEIGHT = 26
local ZONE_LENGTH = 7000

local colors = {
    rock         = { 0.62, 0.63, 0.68 },
    rockEdge     = { 0.80, 0.81, 0.86 },
    crater       = { 0.48, 0.49, 0.55 },
    wall         = { 0.45, 0.46, 0.53 },
    wallEdge     = { 0.66, 0.67, 0.74 },
    outline      = { 0.12, 0.13, 0.18 },
    crystal      = { 0.95, 0.35, 0.47 },
    meteor       = { 0.55, 0.38, 0.28 },
    meteorCrater = { 0.38, 0.25, 0.18 },
    trail        = { 1.0,  0.55, 0.2  },
    deck         = { 0.20, 0.23, 0.30 },
    deckEdge     = { 0.55, 0.60, 0.70 },
    seam         = { 0.12, 0.14, 0.19 },
    bulkhead     = { 0.30, 0.34, 0.43 },
    bulkheadLine = { 0.40, 0.45, 0.55 },
    hazardYellow = { 0.95, 0.78, 0.15 },
    hazardBlack  = { 0.10, 0.10, 0.12 },
    light        = { 0.4,  0.9,  1.0  },
    debris       = { 0.62, 0.64, 0.70 },
    debrisStripe = { 0.85, 0.45, 0.20 },
    fish         = { 1.0,  0.62, 0.25 },
}

local function rand(a, b)
    return a + math.random() * (b - a)
end

local function overlaps(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
       and a.y < b.y + b.h and b.y < a.y + a.h
end

local function circleHitsRect(cx, cy, r, rect)
    local nx = math.max(rect.x, math.min(cx, rect.x + rect.w))
    local ny = math.max(rect.y, math.min(cy, rect.y + rect.h))
    local dx, dy = cx - nx, cy - ny
    return dx * dx + dy * dy < r * r
end

local function makeCraters(count, width, yMin, yMax)
    local list = {}
    for i = 1, count do
        list[i] = { x = rand(0, width), y = rand(yMin, yMax), r = rand(4, 14) }
    end
    return list
end

require("src.world.spawn")(World, colors, rand, overlaps, SPIKE_HEIGHT)

local ents = require("src.world.draw")(colors)

function World.new(width, height, floorY, ceilY)
    local self = setmetatable({}, World)
    self.width, self.height = width, height
    self.floorY, self.ceilY = floorY, ceilY
    self.entities = {}
    self.solids = {}
    self.time = 0
    self.clock = 0
    self.scrolled = 0
    self.spawning = false
    self.spawnTimer = 1.2
    self.floorCraters = makeCraters(18, width, floorY + 16, height - 10)
    self.ceilCraters = makeCraters(18, width, 10, ceilY - 16)
    return self
end

function World:zoneAt(worldX)
    if math.floor(worldX / ZONE_LENGTH) % 2 == 0 then return "moon" end
    return "station"
end

function World:difficulty()
    return math.min(self.time / 90, 1)
end

function World:add(entity)
    entity.zone = self:zoneAt(self.scrolled + entity.x)
    table.insert(self.entities, entity)
    return entity
end

function World:update(dt, speed)
    self.clock = self.clock + dt
    self.scrolled = self.scrolled + speed * dt
    if self.spawning then
        self.time = self.time + dt
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then self:spawnPattern() end
    end

    local solids = {}
    for i = #self.entities, 1, -1 do
        local e = self.entities[i]
        local right
        if e.kind == "meteor" then
            e.x = e.x + (e.vx - speed) * dt
            e.y = e.y + e.vy * dt
            if e.y - e.r < self.ceilY then
                e.y, e.vy = self.ceilY + e.r, math.abs(e.vy)
            elseif e.y + e.r > self.floorY then
                e.y, e.vy = self.floorY - e.r, -math.abs(e.vy)
            end
            e.angle = e.angle + e.spin * dt
            e.trailVX, e.trailVY = e.vx - speed, e.vy
            right = e.x + e.r
        else
            e.x = e.x - speed * dt
            if e.kind == "fish" then e.bob = e.bob + dt * 4 end
            right = e.x + e.w
        end

        if e.collected or right < -80 then
            table.remove(self.entities, i)
        elseif e.kind == "wall" then
            solids[#solids + 1] = e
        end
    end
    self.solids = solids
end

local function spikeHitbox(e)
    local tipInset = 8
    if e.ceiling then
        return { x = e.x + 6, y = e.y, w = e.w - 12, h = e.h - tipInset }
    end
    return { x = e.x + 6, y = e.y + tipInset, w = e.w - 12, h = e.h - tipInset }
end

function World:collide(player)
    local hit, fish = false, {}
    for _, e in ipairs(self.entities) do
        if e.kind == "spikes" then
            if overlaps(player, spikeHitbox(e)) then hit = true end
        elseif e.kind == "meteor" then
            if circleHitsRect(e.x, e.y, e.r * 0.85, player) then hit = true end
        elseif e.kind == "fish" and not e.collected then
            if overlaps(player, e) then
                e.collected = true
                table.insert(fish, e)
            end
        end
    end
    return hit, fish
end

local function drawCraters(craters, offset, width, x0, x1)
    for _, c in ipairs(craters) do
        local x = (c.x - offset) % width
        for _, cx in ipairs({ x, x - width }) do
            if cx >= x0 and cx < x1 then love.graphics.circle("fill", cx, c.y, c.r) end
        end
    end
end

function World:drawMoonBounds(x0, x1)
    local w = x1 - x0
    love.graphics.setColor(colors.rock)
    love.graphics.rectangle("fill", x0, self.floorY, w, self.height - self.floorY)
    love.graphics.rectangle("fill", x0, 0, w, self.ceilY)

    love.graphics.setColor(colors.rockEdge)
    love.graphics.rectangle("fill", x0, self.floorY, w, 6)
    love.graphics.rectangle("fill", x0, self.ceilY - 6, w, 6)

    love.graphics.setColor(colors.crater)
    local offset = self.scrolled % self.width
    drawCraters(self.floorCraters, offset, self.width, x0, x1)
    drawCraters(self.ceilCraters, offset, self.width, x0, x1)
end

local function eachGridLine(scrolled, spacing, x0, x1, fn)
    local index = math.ceil((scrolled + x0) / spacing)
    local x = index * spacing - scrolled
    while x < x1 do
        fn(x, index)
        index = index + 1
        x = x + spacing
    end
end

local function drawHazardStripe(scrolled, x0, x1, y, h)
    local block = 20
    eachGridLine(scrolled, block, x0 - block, x1, function(x, index)
        local left, right = math.max(x, x0), math.min(x + block, x1)
        if right > left then
            love.graphics.setColor(index % 2 == 0 and colors.hazardYellow or colors.hazardBlack)
            love.graphics.rectangle("fill", left, y, right - left, h)
        end
    end)
end

function World:drawStationBand(x0, x1, y, h, edgeY, stripeY)
    love.graphics.setColor(colors.deck)
    love.graphics.rectangle("fill", x0, y, x1 - x0, h)

    love.graphics.setLineWidth(2)
    eachGridLine(self.scrolled, 96, x0, x1, function(x)
        love.graphics.setColor(colors.seam)
        love.graphics.line(x, y, x, y + h)
        love.graphics.setColor(colors.deckEdge)
        love.graphics.rectangle("fill", x + 6, y + h / 2 - 2, 4, 4)
    end)

    local blink = math.sin(self.clock * 3) > 0
    eachGridLine(self.scrolled, 192, x0, x1, function(x, index)
        if blink == (index % 2 == 0) then
            love.graphics.setColor(colors.light)
            love.graphics.circle("fill", x + 48, y + h / 2, 4)
        end
    end)

    love.graphics.setColor(colors.deckEdge)
    love.graphics.rectangle("fill", x0, edgeY, x1 - x0, 4)
    drawHazardStripe(self.scrolled, x0, x1, stripeY, 8)
end

function World:drawStationBounds(x0, x1)
    self:drawStationBand(x0, x1, self.floorY, self.height - self.floorY, self.floorY, self.floorY + 6)
    self:drawStationBand(x0, x1, 0, self.ceilY, self.ceilY - 4, self.ceilY - 14)
end

function World:drawBounds()
    local x0 = 0
    while x0 < self.width do
        local worldX = self.scrolled + x0
        local zoneEnd = (math.floor(worldX / ZONE_LENGTH) + 1) * ZONE_LENGTH - self.scrolled
        local x1 = math.min(self.width, zoneEnd)
        if self:zoneAt(worldX) == "moon" then
            self:drawMoonBounds(x0, x1)
        else
            self:drawStationBounds(x0, x1)
        end
        x0 = x1
    end
end

function World:draw()
    for _, e in ipairs(self.entities) do
        if e.kind == "wall" then ents.drawWall(e)
        elseif e.kind == "spikes" then ents.drawSpikes(e, self.clock)
        elseif e.kind == "meteor" then
            if e.zone == "station" then ents.drawDebris(e) else ents.drawMeteor(e) end
        elseif e.kind == "fish" then ents.drawFish(e)
        end
    end
end

function World:drawHitboxes()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0, 1, 0)
    for _, e in ipairs(self.entities) do
        if e.kind == "meteor" then
            love.graphics.circle("line", e.x, e.y, e.r * 0.85)
        elseif e.kind == "spikes" then
            local h = spikeHitbox(e)
            love.graphics.rectangle("line", h.x, h.y, h.w, h.h)
        else
            love.graphics.rectangle("line", e.x, e.y, e.w, e.h)
        end
    end
end

return World
