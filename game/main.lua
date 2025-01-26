local sprite = require("sprite")
local platforms = require("platforms")

function love.load()
    love.window.setMode(800, 600, {resizable=false})
    -- love.window.setTitle("Scrolling Platforms - Closer & Solid")

   

    love.graphics.setBackgroundColor(0.5, 0.7, 1) -- sky-blue

    sprite.load()
    platforms.load()
end

function love.update(dt)
    platforms.update(dt)

    sprite.update(dt, platforms.getList())
end

function love.draw()
    platforms.draw() 
    sprite.draw()

    -- love.graphics.setColor(0.3, 0.8, 0.3)
    -- love.graphics.rectangle("fill", 0, 550, 800, 50)
    -- love.graphics.setColor(1,1,1)
end
