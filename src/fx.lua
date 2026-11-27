local fx = {}

local particles = {}
local popups = {}
local shake = 0

function fx.reset()
    particles = {}
    popups = {}
    shake = 0
end

function fx.burst(x, y, count, color, opts)
    opts = opts or {}
    local speed = opts.speed or 160
    for _ = 1, count do
        local angle = math.random() * math.pi * 2
        local s = speed * (0.4 + math.random() * 0.6)
        local life = 0.35 + math.random() * 0.3
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * s + (opts.vx or 0),
            vy = math.sin(angle) * s + (opts.vy or 0),
            gravity = opts.gravity or 0,
            size = opts.size or 4,
            life = life, maxLife = life,
            color = color,
        })
    end
end

function fx.popup(text, x, y)
    table.insert(popups, { text = text, x = x, y = y, life = 0.8 })
end

function fx.shake(amount)
    shake = math.max(shake, amount)
end

function fx.update(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(particles, i)
        else
            p.vy = p.vy + p.gravity * dt
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
        end
    end
    for i = #popups, 1, -1 do
        local p = popups[i]
        p.life = p.life - dt
        p.y = p.y - 60 * dt
        if p.life <= 0 then table.remove(popups, i) end
    end
    shake = math.max(0, shake - dt)
end

function fx.shakeOffset()
    if shake <= 0 then return 0, 0 end
    local strength = shake * 30
    return (math.random() * 2 - 1) * strength, (math.random() * 2 - 1) * strength
end

function fx.draw(font)
    for _, p in ipairs(particles) do
        local c = p.color
        love.graphics.setColor(c[1], c[2], c[3], p.life / p.maxLife)
        love.graphics.rectangle("fill", p.x - p.size / 2, p.y - p.size / 2, p.size, p.size)
    end
    love.graphics.setFont(font)
    for _, p in ipairs(popups) do
        love.graphics.setColor(1, 0.85, 0.3, math.min(1, p.life * 2))
        love.graphics.print(p.text, p.x, p.y)
    end
end

return fx
