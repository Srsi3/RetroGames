local platforms = {}

local platformList = {}

local platformImage
local platformQuad

local TILE_WIDTH  = 48
local TILE_HEIGHT = 16



-- Scroll speed
local SCROLL_SPEED = 100

-- Number of platforms on screen
local NUM_PLATFORMS = 6

-- Gaps
local BASE_GAP  = 200
local GAP_VARIANCE = 20

-- Vertical range
local MIN_Y = 150
local MAX_Y = 450

function spawnStartPlatform(x, y)
    local p = {}

    local scale = 2
    p.scale = scale

    p.width  = TILE_WIDTH  * scale
    p.height = TILE_HEIGHT * scale

    p.x = x
    p.y = y

    return p
end

-- Helper to spawn a new platform at a given x
local function spawnPlatform(x)
    local p = {}

    local scale = 2
    p.scale = scale

    p.width  = TILE_WIDTH  * scale
    p.height = TILE_HEIGHT * scale

    p.x = x
    p.y = love.math.random(player.y - 50, player.y + 50)

    return p
end

function platforms.load()
    platformImage = love.graphics.newImage("assets/DirtTiles.png")
    platformImage:setFilter("nearest", "nearest")

    -- We'll use the top-left 32x32 portion of the image
    platformQuad = love.graphics.newQuad(
        0, 0,
        TILE_WIDTH, TILE_HEIGHT,
        platformImage:getWidth(), platformImage:getHeight()
    )
    local width, height, flags = love.window.getMode( )
    local x = 100
    local y = height/2 + (17 * 4)
    local firstPlat = spawnStartPlatform(x, y)
    table.insert(platformList, firstPlat)
    local secondPlat = spawnStartPlatform(x+80, y)
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
    -- Scroll left
    for _, p in ipairs(platformList) do
        Result = love.timer.getTime() - Start
        p.x = p.x - math.max(60*dt, SCROLL_SPEED * dt * (Result / 10))
    end

    -- Check if the leftmost platform is off-screen
    local firstPlatform = platformList[1]
    if firstPlatform and (firstPlatform.x + firstPlatform.width < 0) then
        -- Remove it
        table.remove(platformList, 1)

        -- Spawn a new platform on the right
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

return platforms
