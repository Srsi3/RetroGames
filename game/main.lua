function love.load()
    -- Load the sprite sheet
    image = love.graphics.newImage("assets/CharacterSheet.png")
    image:setFilter("nearest", "nearest") 
    
    -- Define a table to hold all animations
    -- For clarity, each animation is another table containing the frames (Quads)
    frames = {
        idle = {
            -- x=2, y=15, width=14, height=17
            love.graphics.newQuad(2, 15, 14, 17, image:getWidth(), image:getHeight())
        },
        run = {
            -- Here we assume each subsequent frame is 16 pixels over in x
            love.graphics.newQuad(2,   47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(18,  47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(34,  47, 14, 17, image:getWidth(), image:getHeight()),
            love.graphics.newQuad(50,  47, 14, 17, image:getWidth(), image:getHeight())
        },
        jump = {
            love.graphics.newQuad(2, 78, 14, 18, image:getWidth(), image:getHeight())
        },
        fall = {
            love.graphics.newQuad(18, 78, 14, 16, image:getWidth(), image:getHeight())
        }
    }

    -- Track which animation is currently playing (state)
    currentState = "idle"
    
    -- Current frame index within that state
    currentFrame = 1
    -- How fast to advance frames (in seconds)
    animationSpeed = 0.1
    -- Accumulator for elapsed time
    animationTimer = 0
end




function love.update(dt)
    local isJumping     = love.keyboard.isDown('w')
    local isCrouching   = love.keyboard.isDown('s')
    local isMovingLeft  = love.keyboard.isDown('a')
    local isMovingRight = love.keyboard.isDown('d')

    local newState

    -- 1) Jump has highest priority
    if isCrouching then
        newState = "fall"
    -- 2) Then crouch
    elseif isJumping then
        newState = "jump"
    -- 3) Then run (if left or right is down)
    elseif isMovingLeft or isMovingRight then
        newState = "run"
    -- 4) Otherwise idle
    else
        newState = "idle"
    end

    -- If we detect a change in state, reset the animation
    if newState ~= currentState then
        currentState = newState
        currentFrame = 1
        animationTimer = 0
    end

    -- Update the animation timer and frame
    animationTimer = animationTimer + dt
    if animationTimer >= animationSpeed then
        animationTimer = 0
        currentFrame = currentFrame + 1
        -- Wrap around if needed
        if currentFrame > #frames[currentState] then
            currentFrame = 1
        end
    end

    -- (Optional) Movement / physics code...
end

function love.draw()
    -- We'll display the current frame of the current animation
    local quad = frames[currentState][currentFrame]

    -- Example scaling: original frames are 14x17, we want 4x scale
    local desiredWidth = 14 * 4  
    local desiredHeight = 17 * 4 
    local scale = math.min(desiredWidth / 14, desiredHeight / 17)
    
    -- Draw the current frame
    love.graphics.draw(image, quad, 100, 100, 0, scale, scale)
end
