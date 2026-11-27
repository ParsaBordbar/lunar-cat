local anim8 = require("libraries.anim8")

local Player = {}
Player.__index = Player

local SCALE = 3
local GRAVITY = 2400
local MAX_FALL_SPEED = 1300
local JUMP_SPEED = 820
local JUMP_CUT = 0.45
local MOVE_SPEED = 380
local MAX_JUMPS = 2
local COYOTE_TIME = 0.08
local FLIP_PUSH = 160

local sheets

local IDLE_HEAD_ROW = { 14, 14, 15, 15, 16, 16, 15 }
local JUMP_HEAD_ROW = { 13, 10, 6, 10, 15, 18, 20, 21, 22, 19 }

local function overlaps(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
       and a.y < b.y + b.h and b.y < a.y + a.h
end

function Player.load()
    sheets = {
        idle = love.graphics.newImage("assets/player/IdleCat.png"),
        jump = love.graphics.newImage("assets/player/JumpCat.png"),
    }
end

function Player.new(x, y, maxX)
    local idleGrid = anim8.newGrid(32, 32, sheets.idle:getWidth(), sheets.idle:getHeight())
    local jumpGrid = anim8.newGrid(32, 32, sheets.jump:getWidth(), sheets.jump:getHeight())

    local self = setmetatable({}, Player)
    self.x, self.y = x, y
    self.w, self.h = 54, 48
    self.maxX = maxX
    self.vy = 0
    self.dir = 1
    self.grounded = true
    self.justLanded = false
    self.coyote = 0
    self.jumpsLeft = MAX_JUMPS
    self.airFlip = true
    self.clock = 0
    self.anims = {
        idle = anim8.newAnimation(idleGrid("1-7", 1), 0.1),
        jump = anim8.newAnimation(jumpGrid("4-13", 1), 0.065, "pauseAtEnd"),
    }
    return self
end

function Player:onSurface()
    return self.grounded or self.coyote > 0
end

function Player:startJumpAnimation()
    self.anims.jump:gotoFrame(1)
    self.anims.jump:resume()
end

function Player:jump()
    if self:onSurface() then
        self.jumpsLeft = MAX_JUMPS - 1
    elseif self.jumpsLeft > 0 then
        self.jumpsLeft = self.jumpsLeft - 1
    else
        return false
    end
    self.vy = -JUMP_SPEED * self.dir
    self.grounded = false
    self.coyote = 0
    self:startJumpAnimation()
    return true
end

function Player:cutJump()
    if self.vy * self.dir < 0 then
        self.vy = self.vy * JUMP_CUT
    end
end

function Player:flip()
    if self:onSurface() then
        self.dir = -self.dir
        self.vy = FLIP_PUSH * self.dir
    elseif self.airFlip then
        self.airFlip = false
        self.dir = -self.dir
        self.vy = self.vy * 0.3
    else
        return false
    end
    self.grounded = false
    self.coyote = 0
    self.jumpsLeft = MAX_JUMPS - 1
    self:startJumpAnimation()
    return true
end

function Player:pushOutOf(solids)
    for _, s in ipairs(solids) do
        if overlaps(self, s) then
            self.x = s.x - self.w
        end
    end
end

function Player:update(dt, move, solids, floorY, ceilY)
    if move ~= 0 then
        local newX = self.x + move * MOVE_SPEED * dt
        if move < 0 then
            newX = math.max(newX, math.min(self.x, 0))
        end
        self.x = math.min(newX, self.maxX)
        for _, s in ipairs(solids) do
            if overlaps(self, s) then
                if move > 0 then self.x = s.x - self.w else self.x = s.x + s.w end
            end
        end
    end

    self.vy = self.vy + GRAVITY * self.dir * dt
    self.vy = math.max(-MAX_FALL_SPEED, math.min(MAX_FALL_SPEED, self.vy))
    self.y = self.y + self.vy * dt

    local wasGrounded = self.grounded
    self.grounded = false
    for _, s in ipairs(solids) do
        if overlaps(self, s) then
            if self.vy > 0 then
                self.y = s.y - self.h
                if self.dir == 1 then self.grounded = true end
            elseif self.vy < 0 then
                self.y = s.y + s.h
                if self.dir == -1 then self.grounded = true end
            end
            self.vy = 0
        end
    end
    if self.y + self.h > floorY then
        self.y = floorY - self.h
        self.vy = 0
        if self.dir == 1 then self.grounded = true end
    elseif self.y < ceilY then
        self.y = ceilY
        self.vy = 0
        if self.dir == -1 then self.grounded = true end
    end

    self.justLanded = self.grounded and not wasGrounded
    if self.grounded then
        self.jumpsLeft = MAX_JUMPS
        self.airFlip = true
        self.coyote = COYOTE_TIME
    else
        self.coyote = math.max(0, self.coyote - dt)
        if self.coyote == 0 and self.jumpsLeft == MAX_JUMPS then
            self.jumpsLeft = MAX_JUMPS - 1
        end
    end

    self.clock = self.clock + dt
    if self.grounded then
        self.anims.idle:update(dt)
    else
        self.anims.jump:update(dt)
    end
end

function Player:feet()
    local y = self.dir == 1 and (self.y + self.h) or self.y
    return self.x + self.w / 2, y
end

local function drawFishbowl(headY, clock)
    local cx, cy, r = 22.5, headY - 0.5, 9.5
    local rimY = cy + r - 2

    love.graphics.setColor(0.65, 0.88, 1, 0.12)
    love.graphics.circle("fill", cx, cy, r, 32)

    love.graphics.setColor(0.9, 0.97, 1, 0.7)
    for k = 0, 2 do
        local rise = (clock * 7 + k * 5) % 13
        love.graphics.circle("fill", cx + 3 - k * 2.5, rimY - 1 - rise, 0.6, 8)
    end

    love.graphics.setLineWidth(0.7)
    love.graphics.setColor(0.85, 0.95, 1, 0.9)
    love.graphics.circle("line", cx, cy, r, 32)

    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.arc("line", "open", cx, cy, r - 2, math.pi * 1.1, math.pi * 1.45, 10)
    love.graphics.circle("fill", cx - 4.5, cy - 5.5, 0.8, 8)

    love.graphics.setColor(0.72, 0.82, 0.95)
    love.graphics.rectangle("fill", cx - 6.5, rimY, 13, 2.2)
    love.graphics.setColor(0.4, 0.9, 1)
    love.graphics.rectangle("fill", cx - 1, rimY + 0.5, 2, 1.2)
end

function Player:draw(tint)
    local anim, sheet, footRow, headRows
    if self.grounded then
        anim, sheet, footRow, headRows = self.anims.idle, sheets.idle, 30, IDLE_HEAD_ROW
    else
        anim, sheet, footRow, headRows = self.anims.jump, sheets.jump, 31, JUMP_HEAD_ROW
    end
    local fx, fy = self:feet()

    love.graphics.push()
    love.graphics.translate(math.floor(fx + 0.5), math.floor(fy + 0.5))
    love.graphics.scale(SCALE, SCALE * self.dir)
    love.graphics.translate(-16, -footRow)

    if tint then love.graphics.setColor(tint) else love.graphics.setColor(1, 1, 1) end
    anim:draw(sheet, 0, 0)
    drawFishbowl(headRows[anim.position], self.clock)

    love.graphics.pop()
end

return Player
