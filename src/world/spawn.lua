return function(World, colors, rand, overlaps, SPIKE_HEIGHT)

    function World:addWall(x, w, h, onCeiling)
        local y = onCeiling and self.ceilY or (self.floorY - h)
        local spots = {}
        for i = 1, math.floor(h / 40) + 1 do
            spots[i] = { x = rand(8, w - 8), y = rand(8, h - 8), r = rand(3, 7) }
        end
        return self:add({ kind = "wall", x = x, y = y, w = w, h = h, ceiling = onCeiling, spots = spots })
    end

    function World:addSpikes(x, w, onCeiling)
        local y = onCeiling and self.ceilY or (self.floorY - SPIKE_HEIGHT)
        return self:add({ kind = "spikes", x = x, y = y, w = w, h = SPIKE_HEIGHT, ceiling = onCeiling })
    end

    function World:spawnGate(x, d)
        local gap = 230 - 40 * d
        local top = rand(self.ceilY + 70, self.floorY - 70 - gap)
        local w = rand(50, 80)
        self:addWall(x, w, top - self.ceilY, true)
        self:addWall(x, w, self.floorY - (top + gap), false)
    end

    function World:spawnMeteors(x, d)
        local count = math.random(1, 1 + math.floor(d * 2.5))
        for _ = 1, count do
            local r = rand(16, 28)
            self:add({
                kind = "meteor",
                x = x + r + rand(0, 260),
                y = rand(self.ceilY + r + 10, self.floorY - r - 10),
                r = r,
                vx = -rand(80, 240), vy = rand(-90, 90),
                angle = rand(0, 6.28), spin = rand(-3, 3),
                trailVX = 0, trailVY = 0,
            })
        end
    end

    function World:spawnFish(x)
        local fish = {
            kind = "fish",
            x = x, y = rand(self.ceilY + 30, self.floorY - 50),
            w = 40, h = 24, bob = rand(0, 6),
        }
        for _, e in ipairs(self.entities) do
            if e.kind ~= "meteor" and overlaps(fish, e) then return end
        end
        self:add(fish)
    end

    function World:spawnPattern()
        local d = self:difficulty()
        local x = self.width + 60
        local roll = math.random()
        local meteorChance = self.time > 10 and (0.12 + 0.23 * d) or 0

        if roll < meteorChance then
            self:spawnMeteors(x, d)
        elseif roll < meteorChance + 0.22 then
            self:spawnGate(x, d)
        elseif roll < meteorChance + 0.42 then
            self:addSpikes(x, rand(100, 160 + 80 * d), math.random() < 0.5)
        else
            local onCeiling = math.random() < 0.5
            self:addWall(x, rand(50, 90), rand(80, 200 + 60 * d), onCeiling)
            if d > 0.35 and math.random() < 0.4 then
                self:addSpikes(x - 40, 180, not onCeiling)
            end
        end

        if math.random() < 0.55 then
            self:spawnFish(x + rand(180, 320))
        end
        self.spawnTimer = rand(0.95, 1.5) * (1 - 0.3 * d)
    end
end
