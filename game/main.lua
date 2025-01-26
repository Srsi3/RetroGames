local sprite    = require("sprite")
local platforms = require("platforms")

local gameState = "start"

local backgroundImage
local startImage



function love.load()
    backgroundImage = love.graphics.newImage("assets/background.png")
    backgroundImage:setFilter("nearest", "nearest")

    local bgWidth  = backgroundImage:getWidth()
    local bgHeight = backgroundImage:getHeight()
    love.window.setMode(bgWidth, bgHeight, {resizable=true})
    love.window.setTitle("Platformer with Start Screen")

    startImage = love.graphics.newImage("assets/Just_Stop.png")
    startImage:setFilter("nearest", "nearest")

    sprite.load()
    platforms.load()
end

function love.update(dt)
    if gameState == "start" then
    elseif gameState == "play" then
        platforms.update(dt)
        sprite.update(dt, platforms.getList())
    end
end

function love.draw()
    love.graphics.draw(backgroundImage, 0, 0)

    if gameState == "start" then
        
        local sw = startImage:getWidth()
        local sh = startImage:getHeight()
        local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
        local x = (windowW - sw) / 2
        local y = (windowH - sh) / 2

        love.graphics.draw(startImage, x, y)

        -- love.graphics.printf("Press any key to start", 0, windowH*0.8, windowW, "center")

    elseif gameState == "play" then
        
        platforms.draw()
        sprite.draw()
        
        
    end
end

function love.keypressed(key)
    if gameState == "start" then
        gameState = "play"
    else
    end
end
