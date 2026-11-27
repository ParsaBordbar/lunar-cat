local ui = {}

local WIDTH = 1280
local BOOT_COLOR = { 0.4, 0.9, 1.0 }
local BANNER_TIME = 2.5

local CONTROLS = {
    [1] = "Switch:  Stick / D-pad move   A, B jump   X, Y, L, R, ZL, ZR flip gravity   + pause",
    [2] = "Keyboard:  A D / arrows move   Space jump   W / Up / Shift flip gravity   Enter pause",
}

local function shadowPrint(text, x, y)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.print(text, x + 2, y + 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, x, y)
end

local function centeredText(text, y, font, color)
    color = color or { 1, 1, 1 }
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.6 * (color[4] or 1))
    love.graphics.printf(text, 2, y + 2, WIDTH, "center")
    love.graphics.setColor(color)
    love.graphics.printf(text, 0, y, WIDTH, "center")
end

local function dimScreen()
    love.graphics.setColor(0.02, 0.03, 0.08, 0.65)
    love.graphics.rectangle("fill", 0, 0, WIDTH, 720)
end

function ui.drawHud(game, fonts)
    local p = game.player
    love.graphics.setFont(fonts.medium)
    shadowPrint("SCORE " .. game.score, 24, 22)
    shadowPrint("FISH " .. game.fishCount, 260, 22)

    local best = "BEST " .. game.best
    shadowPrint(best, WIDTH - 24 - fonts.medium:getWidth(best), 22)

    local ready = p:onSurface() or p.airFlip
    local label = (p.dir == 1 and "BOOTS: DOWN" or "BOOTS: UP")
    love.graphics.setFont(fonts.small)
    local x = WIDTH / 2 - fonts.small:getWidth(label) / 2
    love.graphics.setColor(ready and BOOT_COLOR or { 0.4, 0.4, 0.45 })
    love.graphics.rectangle("line", x - 12, 24, fonts.small:getWidth(label) + 24, 32, 6, 6)
    love.graphics.print(label, x, 30)

    if game.banner then
        local alpha = math.min(1, game.banner.life, (BANNER_TIME - game.banner.life) * 4)
        centeredText(game.banner.text, 110, fonts.medium, { BOOT_COLOR[1], BOOT_COLOR[2], BOOT_COLOR[3], alpha })
    end
end

function ui.drawOverlay(game, fonts)
    if game.state == "title" then
        dimScreen()
        centeredText("LUNAR CAT", 180, fonts.big, BOOT_COLOR)
        centeredText("From moon rock to space station. Gravity boots on, dodge everything.", 280, fonts.medium)
        centeredText(CONTROLS[1], 380, fonts.small)
        centeredText(CONTROLS[2], 410, fonts.small)
        centeredText("Press A / Space to start", 500, fonts.medium, { 1, 0.85, 0.3 })
        if game.best > 0 then centeredText("Best: " .. game.best, 550, fonts.small) end

    elseif game.state == "paused" then
        dimScreen()
        centeredText("PAUSED", 250, fonts.big)
        centeredText("+ / Enter to resume      - / Esc to quit to title", 360, fonts.medium)

    elseif game.state == "over" then
        dimScreen()
        centeredText("SPLAT!", 200, fonts.big, { 0.95, 0.35, 0.47 })
        centeredText("Score " .. game.score .. "   ·   Fish " .. game.fishCount, 310, fonts.medium)
        if game.newBest then centeredText("NEW BEST!", 360, fonts.medium, { 1, 0.85, 0.3 }) end
        if game.deadTimer >= 0.6 then
            centeredText("A / Space to retry      - / Esc for title", 450, fonts.medium)
        end
    end
end

return ui
