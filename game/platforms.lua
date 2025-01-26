local platforms = {}

local platformList = {}

local platformImage
local platformQuad

-- Base tile size in DirtTiles.png
local TILE_WIDTH  = 32
local TILE_HEIGHT = 32

-- We'll choose a random scale between these values
local MIN_SCALE = 1.5
local MAX_SCALE = 3.5

-- Scroll speed
local SCROLL_SPEED = 60

-- Number of platforms on screen
local NUM_PLATFORMS = 6

-- Gaps
local BASE_GAP     = 100
local GAP_VARIANCE = 20

-- Vertical range
local MIN_Y = 200
local MAX_Y = 450

-- Helper to spawn a new platform at a given x
local function spawnPlatform(x)
    local p = {}

    local scale = love.math.random() * (MAX_SCALE - MIN_SCALE) + MIN_SCALE
    p.scale = scale

    p.width  = TILE_WIDTH  * scale
    p.height = TILE_HEIGHT * scale

    p.x = x
    p.y = love.math.random(MIN_Y, MAX_Y)

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
        p.x = p.x - SCROLL_SPEED * dt
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

        local newPlatform = spawnPlatform(newX)
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
