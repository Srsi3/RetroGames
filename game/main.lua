local sprite = require("sprite")

function love.load()
    sprite.load()
end

function love.update(dt)
    sprite.update(dt)
end

function love.draw()
    sprite.draw()
end
