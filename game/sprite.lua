local sprite = {}

local image
local frames
local currentState
local currentFrame
local animationSpeed
local animationTimer

-- Player physics and positioning
local player = {
    x = 100,
    y = 100,
    width = 14 * 4,  -- scaled up from sprite size
    height = 17 * 4, -- scaled up from sprite size
    vx = 0,
    vy = 0,
    speed = 100,     -- horizontal movement speed
    jumpForce = 250,
    onGround = false
}

local gravity = 600
local groundY = 500 -- The y-position of our ground

function sprite.load()
    -- Load sprite sheet
    image = love.graphics.newImage("assets/CharacterSheet.png")
    -- Nearest filter so our pixel art remains crisp
    image:setFilter("nearest", "nearest")

    -- Define the frames in the sprite sheet
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

    currentState     = "idle"
    currentFrame     = 1
    animationSpeed   = 0.1
    animationTimer   = 0
end

function sprite.update(dt)
    -- Check movement inputs
    local moveLeft  = love.keyboard.isDown('a')
    local moveRight = love.keyboard.isDown('d')

    -- Horizontal movement
    if moveLeft then
        player.vx = -player.speed
    elseif moveRight then
        player.vx = player.speed
    else
        player.vx = 0
    end

    -- Jump: only if on the ground
    if love.keyboard.isDown('w') and player.onGround then
        player.vy = -player.jumpForce
        player.onGround = false
    end

    -- Apply gravity
    player.vy = player.vy + (gravity * dt)

    -- Update player position
    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt

    -- Simple ground collision
    if player.y + player.height > groundY then
        player.y = groundY - player.height
        player.vy = 0
        player.onGround = true
    end

    -- Determine animation state
    local newState = currentState

    if not player.onGround then
        -- If velocity is going upwards, use jump; if going downwards, use fall
        if player.vy < 0 then
            newState = "jump"
        else
            newState = "fall"
        end
    else
        if player.vx ~= 0 then
            newState = "run"
        else
            newState = "idle"
        end
    end

    -- Change animation state if needed
    if newState ~= currentState then
        currentState = newState
        currentFrame = 1
        animationTimer = 0
    end

    -- Handle frame animation timing
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

    -- Draw the sprite at the player's position, scaled up
    -- The original frames for each sprite are around 14x17
    -- We upscaled them by factor of 4 in 'player.width' and 'player.height'
    local scaleX = player.width / 14
    local scaleY = player.height / 17

    -- Flip the sprite if moving left
    local flip = 1
    if player.vx < 0 then
        flip = -1
    end

    -- When flipping horizontally, we’ll need to offset so the character
    -- doesn’t jump to the other side of the pivot
    -- We'll translate by half the width if flipping
    local offsetX = 0
    if flip == -1 then
        offsetX = player.width
    end

    love.graphics.draw(
        image, 
        quad, 
        player.x + offsetX, 
        player.y, 
        0,             -- rotation 
        scaleX * flip, -- scaleX (negative to flip horizontally)
        scaleY         -- scaleY
    )
end

return sprite
