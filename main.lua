local input = require("src.input")
local background = require("src.background")
local fx = require("src.fx")
local Player = require("src.player")
local World = require("src.world.init")
local ui = require("src.ui")

local WIDTH, HEIGHT = 1280, 720
local FLOOR_Y, CEIL_Y = 640, 80
local PLAYER_START_X = 220
local PLAYER_MAX_X = 800

local START_SPEED = 340
local MAX_SPEED = 720
local SPEED_RAMP = 6
local TITLE_SPEED = 120
local FISH_POINTS = 25
local RESTART_DELAY = 0.6
local BANNER_TIME = 2.5

local ZONE_NAMES = {
    moon = "LUNAR SURFACE",
    station = "ORBITAL STATION",
}

local BOOT_COLOR = { 0.4, 0.9, 1.0 }
local DUST_COLOR = { 0.85, 0.86, 0.9 }

local game = {
    state = "title",
    best = 0,
    newBest = false,
    debug = false,
    score = 0,
}
local fonts = {}

local function loadBest()
    local ok, data = pcall(love.filesystem.read, "best.txt")
    return (ok and tonumber(data)) or 0
end

local function saveBest(value)
    pcall(love.filesystem.write, "best.txt", tostring(value))
end

local function calcScore()
    return math.floor(game.distance / 10) + game.fishCount * FISH_POINTS
end

local function newRun()
    game.player = Player.new(PLAYER_START_X, FLOOR_Y - 48, PLAYER_MAX_X)
    game.world = World.new(WIDTH, HEIGHT, FLOOR_Y, CEIL_Y)
    game.speed = START_SPEED
    game.distance = 0
    game.fishCount = 0
    game.deadTimer = 0
    game.newBest = false
    game.zone = "moon"
    game.banner = nil
    game.score = 0
    fx.reset()
end

local function showBanner(text)
    game.banner = { text = text, life = BANNER_TIME }
end

local function startRun()
    newRun()
    game.world.spawning = true
    game.state = "play"
    showBanner(ZONE_NAMES.moon)
end

local function die()
    local p = game.player
    game.state = "over"
    game.deadTimer = 0
    fx.burst(p.x + p.w / 2, p.y + p.h / 2, 40, DUST_COLOR, { speed = 380, size = 6 })
    fx.shake(0.4)

    local final = calcScore()
    if final > game.best then
        game.best = final
        game.newBest = true
        saveBest(final)
    end
end

local function bootBurst(p)
    fx.burst(p.x + p.w / 2, p.y + p.h / 2, 16, BOOT_COLOR, { speed = 220, size = 5 })
end

local function dustAtFeet(p, count)
    local x, y = p:feet()
    fx.burst(x, y, count, DUST_COLOR, { speed = 120, vy = -80 * p.dir, gravity = 300 * p.dir })
end

local function handleAction(action)
    local state = game.state
    local p = game.player

    if state == "title" then
        if action == "jump" or action == "pause" then startRun()
        elseif action == "back" then love.event.quit() end

    elseif state == "play" then
        if action == "jump" then
            if p:jump() then dustAtFeet(p, 6) end
        elseif action == "jumpRelease" then
            p:cutJump()
        elseif action == "flip" then
            if p:flip() then bootBurst(p) end
        elseif action == "pause" or action == "back" then
            game.state = "paused"
        end

    elseif state == "paused" then
        if action == "pause" or action == "jump" then
            game.state = "play"
        elseif action == "back" then
            newRun()
            game.state = "title"
        end

    elseif state == "over" then
        if game.deadTimer < RESTART_DELAY then return end
        if action == "jump" or action == "pause" then
            startRun()
        elseif action == "back" then
            newRun()
            game.state = "title"
        end
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())

    fonts.big = love.graphics.newFont(72)
    fonts.medium = love.graphics.newFont(28)
    fonts.small = love.graphics.newFont(18)

    background.load()
    Player.load()
    game.best = loadBest()
    newRun()
end

local function updatePlay(dt)
    local p, world = game.player, game.world

    game.speed = math.min(MAX_SPEED, game.speed + SPEED_RAMP * dt)
    game.distance = game.distance + game.speed * dt
    game.score = calcScore()
    world:update(dt, game.speed)

    local zone = world:zoneAt(world.scrolled + p.x)
    if zone ~= game.zone then
        game.zone = zone
        showBanner(ZONE_NAMES[zone])
    end

    p:pushOutOf(world.solids)
    p:update(dt, input.horizontal(), world.solids, FLOOR_Y, CEIL_Y)
    if p.justLanded then dustAtFeet(p, 8) end

    local hit, fish = world:collide(p)
    for _, f in ipairs(fish) do
        game.fishCount = game.fishCount + 1
        fx.popup("+" .. FISH_POINTS, f.x, f.y - 10)
        fx.burst(f.x + f.w / 2, f.y + f.h / 2, 10, { 1, 0.75, 0.3 }, { speed = 150 })
    end

    if hit or p.x + p.w < 0 then die() end
end

function love.update(dt)
    dt = math.min(dt, 1 / 30)
    fx.update(dt)
    if game.banner then
        game.banner.life = game.banner.life - dt
        if game.banner.life <= 0 then game.banner = nil end
    end

    if game.state == "play" then
        updatePlay(dt)
    elseif game.state == "title" then
        game.world:update(dt, TITLE_SPEED)
        game.player:update(dt, 0, {}, FLOOR_Y, CEIL_Y)
    elseif game.state == "over" then
        game.deadTimer = game.deadTimer + dt
    end
end

function love.draw()
    local world, p = game.world, game.player

    love.graphics.push()
    love.graphics.translate(fx.shakeOffset())

    background.draw()
    world:drawBounds()
    world:draw()
    p:draw(game.state == "over" and { 1, 0.5, 0.5 } or nil)
    fx.draw(fonts.medium)

    if game.debug then
        world:drawHitboxes()
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", p.x, p.y, p.w, p.h)
    end

    love.graphics.pop()

    if game.state ~= "title" then ui.drawHud(game, fonts) end
    ui.drawOverlay(game, fonts)
end

function love.keypressed(key)
    if key == "f1" then
        game.debug = not game.debug
        return
    end
    local action = input.actionForKey(key)
    if action then handleAction(action) end
end

function love.keyreleased(key)
    if input.actionForKey(key) == "jump" then handleAction("jumpRelease") end
end

function love.gamepadpressed(joystick, button)
    local action = input.actionForButton(button)
    if action then handleAction(action) end
end

function love.gamepadreleased(joystick, button)
    if input.actionForButton(button) == "jump" then handleAction("jumpRelease") end
end

function love.gamepadaxis(joystick, axis, value)
    local action = input.actionForTrigger(joystick, axis, value)
    if action then handleAction(action) end
end

function love.focus(focused)
    if not focused and game.state == "play" then
        game.state = "paused"
    end
end
