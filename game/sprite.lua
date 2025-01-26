local sprite = {}

local image
local frames
local currentState
local currentFrame
local animationSpeed
local animationTimer

local player = {
    x = 100,
    y = 100,
    width  = 14 * 4,  
    height = 17 * 4,
    vx = 0,
    vy = 0,
    speed = 120,
    jumpForce = 300,
    onGround = false
}

local gravity = 600
local groundY = 550 

local function checkCollision(a, b)
    return  a.x < b.x + b.width  and
            a.x + a.width  > b.x and
            a.y < b.y + b.height and
            a.y + a.height > b.y
end

function sprite.load()
    image = love.graphics.newImage("assets/CharacterSheet.png")
    image:setFilter("nearest", "nearest")

    frames = {
        idle = {
            love.graphics.newQuad(2, 15, 14, 17, image:getWidth(), image:getHeight())
        },
        run = {
            love.graphics.newQuad(2, 47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(18,47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(34,47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(50,47, 14, 17, image:getWidth(), image:getHeight())
        },
        jump = {
            love.graphics.newQuad(2, 78, 14, 18, image:getWidth(), image:getHeight())
        },
        fall = {
            love.graphics.newQuad(18,78,14, 16, image:getWidth(), image:getHeight())
        }
    }

    currentState   = "idle"
    currentFrame   = 1
    animationSpeed = 0.1
    animationTimer = 0
end

function sprite.update(dt, platformList)
    local moveLeft  = love.keyboard.isDown('a')
    local moveRight = love.keyboard.isDown('d')

    if moveLeft then
        player.vx = -player.speed
    elseif moveRight then
        player.vx = player.speed
    else
        player.vx = 0
    end

    if love.keyboard.isDown('w') and player.onGround then
        player.vy = -player.jumpForce
        player.onGround = false
    end

    player.vy = player.vy + gravity * dt

    local oldX = player.x
    local oldY = player.y

    -- Horizontal Movement and Collision
    player.x = player.x + player.vx * dt
    for _, p in ipairs(platformList) do
        if checkCollision(player, p) then
            if player.vx > 0 then
                -- Colliding with the right side of a platform
                player.x = p.x - player.width
            elseif player.vx < 0 then
                -- Colliding with the left side of a platform
                player.x = p.x + p.width
            end
            player.vx = 0
            break
        end
    end

    -- Vertical Movement and Collision
    player.y = player.y + player.vy * dt
    player.onGround = false
    for _, p in ipairs(platformList) do
        if checkCollision(player, p) then
            if oldY + player.height <= p.y then
                -- Colliding with the top of a platform
                player.y = p.y - player.height
                player.vy = 0
                player.onGround = true
            elseif oldY >= p.y + p.height then
                -- Colliding with the bottom of a platform
                player.y = p.y + p.height
                player.vy = 0
            end
            break
        end
    end

    -- Collision with the ground
    if player.y + player.height > groundY then
        player.y = groundY - player.height
        player.vy = 0
        player.onGround = true
    end

    -- Update animation state
    local newState
    if not player.onGround then
        if player.vy < 0 then
            newState = "jump"
        else
            newState = "fall"
        end
    else
        if math.abs(player.vx) > 0 then
            newState = "run"
        else
            newState = "idle"
        end
    end

    if newState ~= currentState then
        currentState = newState
        currentFrame = 1
        animationTimer = 0
    end

    animationTimer = animationTimer + dt
    if animationTimer >= animationSpeed then
        animationTimer = 0
        currentFrame = currentFrame + 1
        if currentFrame > #frames[currentState] then
            currentFrame = 1
        end
    end
end

function sprite.draw()
    local quad = frames[currentState][currentFrame]

    local scaleX = player.width / 14
    local scaleY = player.height / 17

    local flip = 1
    if player.vx < 0 then
        flip = -1
    end

    local offsetX = 0
    if flip == -1 then
        offsetX = player.width
    end

    love.graphics.draw(
        image,
        quad,
        player.x + offsetX,
        player.y,
        0,
        scaleX * flip,
        scaleY
    )
end

return sprite
