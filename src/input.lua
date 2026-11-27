local input = {}

local DEADZONE = 0.3
local TRIGGER_THRESHOLD = 0.5

local keyActions = {
    space = "jump", j = "jump", z = "jump",
    w = "flip", up = "flip", k = "flip", x = "flip", lshift = "flip", rshift = "flip",
    ["return"] = "pause", p = "pause",
    escape = "back",
}

local buttonActions = {
    a = "jump", b = "jump",
    x = "flip", y = "flip", leftshoulder = "flip", rightshoulder = "flip", dpup = "flip",
    start = "pause",
    back = "back",
}

local triggerActions = {
    triggerleft = "flip",
    triggerright = "flip",
}
local triggerHeld = {}

function input.actionForKey(key)
    return keyActions[key]
end

function input.actionForButton(button)
    return buttonActions[button]
end

function input.actionForTrigger(joystick, axis, value)
    local action = triggerActions[axis]
    if not action then return nil end

    local id = joystick:getID() .. axis
    local held = value > TRIGGER_THRESHOLD
    local wasHeld = triggerHeld[id]
    triggerHeld[id] = held
    if held and not wasHeld then return action end
    return nil
end

function input.horizontal()
    local x = 0
    if love.keyboard and love.keyboard.isDown then
        if love.keyboard.isDown("a", "left") then x = x - 1 end
        if love.keyboard.isDown("d", "right") then x = x + 1 end
    end
    for _, joystick in ipairs(love.joystick.getJoysticks()) do
        if joystick:isGamepad() then
            if joystick:isGamepadDown("dpleft") then x = x - 1 end
            if joystick:isGamepadDown("dpright") then x = x + 1 end
            local axis = joystick:getGamepadAxis("leftx")
            if math.abs(axis) > DEADZONE then x = x + axis end
        end
    end
    return math.max(-1, math.min(1, x))
end

return input
