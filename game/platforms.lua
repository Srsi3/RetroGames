local platforms = {}

local platformList = {}

local platformImage
local platformQuad

local TILE_WIDTH  = 48
local TILE_HEIGHT = 16

-- Scroll speed
local SCROLL_SPEED = 100  -- ← Make sure this is defined at the top so we can reuse it
local NUM_PLATFORMS = 6

local BASE_GAP     = 200
local GAP_VARIANCE = 20
local MIN_Y = 150
local MAX_Y = 450

local function spawnStartPlatform(x, y)
    local p = {}
    p.scale  = 2
    p.width  = TILE_WIDTH  * p.scale
    p.height = TILE_HEIGHT * p.scale
    p.x = x
    p.y = y

    -- We will store oldX (last-frame X) and vx (platform velocity) for convenience
    p.oldX = p.x
    p.vx   = 0
    return p
end

local function spawnPlatform(x)
    local p = {}
    p.scale  = 2
    p.width  = TILE_WIDTH  * p.scale
    p.height = TILE_HEIGHT * p.scale
    p.x = x
    -- Just an example range near the player
    p.y = love.math.random(player.y - 50, player.y + 50)

    p.oldX = p.x
    p.vx   = 0
    return p
end

function platforms.Clear()
    for i=1,#platformList do
        table.remove(platformList, 1)
    end
end

function platforms.load()
    platformImage = love.graphics.newImage("assets/DirtTiles.png")
    platformImage:setFilter("nearest", "nearest")

    platformQuad = love.graphics.newQuad(
        0, 0,
        TILE_WIDTH, TILE_HEIGHT,
        platformImage:getWidth(), platformImage:getHeight()
    )
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local x = 100
    local y = height/2 + (17 * 4)

    local firstPlat  = spawnStartPlatform(x,     y)
    local secondPlat = spawnStartPlatform(x+80,  y)
    table.insert(platformList, firstPlat)
    table.insert(platformList, secondPlat)

    -- Initialize a line of platforms
    local startX = 300
    for i=1, NUM_PLATFORMS do
        local p = spawnPlatform(startX)
        table.insert(platformList, p)
        local randomOffset = love.math.random(-GAP_VARIANCE, GAP_VARIANCE)
        startX = startX + BASE_GAP + randomOffset
    end
end

function platforms.update(dt)
    Result = love.timer.getTime() - Start
    local distanceThisFrame = math.max(60*dt, SCROLL_SPEED * dt * (Result / 10))

    for _, p in ipairs(platformList) do
        -- Store old X so we can compute how much each platform moves
        p.oldX = p.x

        -- Scroll left
        p.x = p.x - distanceThisFrame

        -- Platform velocity (this frame)
        p.vx = p.x - p.oldX
    end

    -- Check if the leftmost platform is off-screen
    local firstPlatform = platformList[1]
    if firstPlatform and (firstPlatform.x + firstPlatform.width < 0) then
        table.remove(platformList, 1)

        -- Spawn a new platform to the right
        local rightmost = platformList[#platformList]
        local newX = rightmost.x + rightmost.width
        local randomOffset = love.math.random(-GAP_VARIANCE, GAP_VARIANCE)
        newX = newX + BASE_GAP + randomOffset

        local newY = rightmost.y +16
        local randomOffsetY = love.math.random(-100, 100)
        newY = newY + randomOffsetY
        if newY < MIN_Y then
            newY = MIN_Y
        elseif newY > MAX_Y then
            newY = MAX_Y
        end

        local newPlatform = spawnStartPlatform(newX, newY)
        table.insert(platformList, newPlatform)
    end
end

function platforms.draw()
    for _, p in ipairs(platformList) do
        love.graphics.draw(
            platformImage,
            platformQuad,
            p.x,
            p.y,
            0,         -- rotation
            p.scale,   -- scaleX
            p.scale    -- scaleY
        )
    end
end

function platforms.getList()
    return platformList
end

-- Optionally expose SCROLL_SPEED if you want to read it in sprite.lua:
function platforms.getScrollSpeed()
    return SCROLL_SPEED
end

return platforms
