
local sprite = {}
local image
local frames
local currentState
local currentFrame
local animationSpeed
local animationTimer

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

    currentState = "idle"
    currentFrame = 1
    animationSpeed = 0.1
    animationTimer = 0
end

function sprite.update(dt)
    local isJumping     = love.keyboard.isDown('w')
    local isFalling   = love.keyboard.isDown('s')
    local isMovingLeft  = love.keyboard.isDown('a')
    local isMovingRight = love.keyboard.isDown('d')

    local newState

    if isFalling then
        newState = "fall"
    elseif isJumping then
        newState = "jump"
    elseif isMovingLeft or isMovingRight then
        newState = "run"
    else
        newState = "idle"
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

    local desiredWidth  = 14 * 4
    local desiredHeight = 17 * 4
    local scale         = math.min(desiredWidth / 14, desiredHeight / 17)

    love.graphics.draw(image, quad, 100, 100, 0, scale, scale)
end

return sprite
