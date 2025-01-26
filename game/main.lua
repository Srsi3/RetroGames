local sprite = require("sprite")

-- Window configuration (optional)
function love.conf(t)
    t.window.width  = 800
    t.window.height = 600
    t.window.title  = "Tiny Platformer Example"
end

function love.load()
    love.graphics.setBackgroundColor(0.5, 0.7, 1)  -- sky-blue background
    sprite.load()
end

function love.update(dt)
    sprite.update(dt)
end

function love.draw()
    sprite.draw()

    -- Draw the 'ground'
    love.graphics.setColor(0.3, 0.8, 0.3) -- greenish ground
    love.graphics.rectangle("fill", 0, 500, 800, 100)

    -- Reset color so other draws aren’t tinted
    love.graphics.setColor(1,1,1)
end
