local sprite = {}

local image
local frames
local currentState
local currentFrame
local animationSpeed
local animationTimer

local platforms = require("platforms")
local width, height = love.graphics.getWidth(), love.graphics.getHeight()

-- We'll also retrieve the scroll speed so we can move the player along with the platform if idle
local SCROLL_SPEED = platforms.getScrollSpeed()

player = {
    x = 100,
    y = height/2,
    width  = 14 * 4,
    height = 17 * 4,
    vx = 0,
    vy = 0,
    speed = 60,
    jumpForce = 400,
    onGround = false,
    currentPlatform = nil  -- We'll track which platform the player is on top of
}

local gravity = 600

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
            love.graphics.newQuad(18,47,14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(34,47,14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(50,47,14, 17, image:getWidth(), image:getHeight())
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

    -- Horizontal input
    if moveLeft then
        player.vx = math.min(-125, -(1.25 * player.speed* dt * (Result / 5)))
    elseif moveRight then
        player.vx = math.max(100, (player.speed* dt * (Result / 5)))
    else
        player.vx = 0
    end

    -- Jump if on ground
    if love.keyboard.isDown('s') and not player.onGround then
      player.vy = player.vy + 100
    elseif love.keyboard.isDown('w') and player.onGround then
        player.vy = -player.jumpForce
        player.onGround = false
        player.currentPlatform = nil

    end

    -- Apply gravity
    player.vy = player.vy + gravity * dt

    local oldX = player.x
    local oldY = player.y

    -- 1) Horizontal movement
    player.x = player.x + player.vx * dt
    for _, p in ipairs(platformList) do
        if checkCollision(player, p) then
            -- Colliding horizontally
            if player.vx > 0 then
                -- from left to right
                player.x = p.x - player.width
            elseif player.vx < 0 then
                -- from right to left
                player.x = p.x + p.width
            end
            player.vx = 0
            break
        end
    end

    -- 2) Vertical movement
    player.y = player.y + player.vy * dt
    player.onGround = false
    player.currentPlatform = nil

    for _, p in ipairs(platformList) do
        if checkCollision(player, p) then
            local wasAbove = (oldY + player.height <= p.y)
            local wasBelow = (oldY >= p.y + p.height)

            if wasAbove then
                player.y = p.y - player.height
                player.vy = 0
                player.onGround = true
                player.currentPlatform = p
            elseif wasBelow then
                player.y = p.y + p.height
                player.vy = 0
            end
            break
        end
    end

    -- If the sprite is on the ground, but not moving left/right, 
    -- add the platform's X velocity to the player so we "stick."
    if player.onGround and player.currentPlatform and (not moveLeft and not moveRight) then
        -- The platform moved p.vx this frame, so move the player by that same amount:
        Result = love.timer.getTime() - Start
        local distanceThisFrame = math.max(60*dt, SCROLL_SPEED * dt * (Result / 10))
        player.x = player.x - distanceThisFrame
    end

    -- If the player goes below the bottom of the window, lose
    if player.y + player.height > height then
        gameState = "lose"
    end

    -- Update animation state
    local newState
    if not player.onGround then
        if player.vy < 0 then
            newState = "jump"
            IdleTime = 0
        else
            newState = "fall"
            IdleTime = 0
        end
    else
        if math.abs(player.vx) > 0 then
            newState = "run"
            IdleTime = 0
        else
            newState = "idle"
            IdleTime  = IdleTime + 1
            
        end
    end

    if newState ~= currentState then
        currentState = newState
        currentFrame = 1
        animationTimer = 0
    end

    -- Advance frames
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

    -- Flip if moving left
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

function sprite.getPosition()
    return player.x, player.y
end

return sprite
