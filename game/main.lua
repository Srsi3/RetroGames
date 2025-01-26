local sprite    = require("sprite")
local platforms = require("platforms")

gameState = "start"
IdleTime = 0
local backgroundImage
local startImage
local winImage


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
        if love.timer.getTime() > 50 and IdleTime > 50 then
            gameState = "win"
            platforms.Clear()
            winImage = love.graphics.newImage("assets/win.png")
        winImage:setFilter("nearest", "nearest")
        end
    elseif gameState == "lose"then
        gameState = "start"
        startImage = love.graphics.newImage("assets/Just_Stop.png")
        startImage:setFilter("nearest", "nearest")
        
        platforms.Clear()
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
        
    elseif gameState == "win" then
        local sw = winImage:getWidth()
        local sh = winImage:getHeight()
        local windowW, windowH = love.graphics.getWidth(), love.graphics.getHeight()
        local x = (windowW - sw) / 2
        local y = (windowH - sh) / 2

        love.graphics.draw(winImage, x, y)
    end
end

function love.keypressed(key)
    print(gameState)
    if gameState == "start" then
        Start = love.timer.getTime()
        
        gameState = "play"
        local width, height, flags = love.window.getMode( )
        player.x = 100
        player.y = height / 2
        platforms.Clear()
        platforms.load()
    else
    end
    print(gameState)
end
