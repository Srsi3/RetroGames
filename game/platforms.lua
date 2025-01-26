local platforms = {}

local platformList = {}

local platformImage
local platformQuad

local TILE_WIDTH  = 32
local TILE_HEIGHT = 32

local SCALE = 2

local SCROLL_SPEED = 60

local NUM_PLATFORMS = 6

local BASE_GAP = 50
local GAP_VARIANCE = 20

local MIN_Y = 200
local MAX_Y = 450

local function spawnPlatform(x)
    local p = {}
    p.width  = TILE_WIDTH  * SCALE
    p.height = TILE_HEIGHT * SCALE
    p.x      = x
    p.y      = love.math.random(MIN_Y, MAX_Y)
    return p
end

function platforms.load()
    platformImage = love.graphics.newImage("assets/DirtTiles.png")
    platformImage:setFilter("nearest", "nearest")

    platformQuad = love.graphics.newQuad(
        0, 0,
        TILE_WIDTH, TILE_HEIGHT,
        platformImage:getDimensions()
    )

    local startX = 200
    for i=1, NUM_PLATFORMS do
        local p = spawnPlatform(startX)
        table.insert(platformList, p)

        local randomOffset = love.math.random(-GAP_VARIANCE, GAP_VARIANCE)
        startX = startX + BASE_GAP + randomOffset
    end
end

function platforms.update(dt)
    for _, p in ipairs(platformList) do
        p.x = p.x - SCROLL_SPEED * dt
    end

    local firstPlatform = platformList[1]
    if firstPlatform and (firstPlatform.x + firstPlatform.width < 0) then
        table.remove(platformList, 1)

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
        love.graphics.draw(platformImage, platformQuad, p.x, p.y, 0, SCALE, SCALE)
    end
end

function platforms.getList()
    return platformList
end

return platforms
