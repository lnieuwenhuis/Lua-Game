love.load = function()
    player = {
        x = 100,
        y = 100,
        radius = 50
    }
    window_width, window_height = love.graphics.getDimensions()
end

love.update = function()
    if love.keyboard.isDown('a') and player.x > 50 then
        player.x = player.x - 5
    elseif love.keyboard.isDown('d') and player.x < window_width - player.radius then
        player.x = player.x + 5
    elseif love.keyboard.isDown('w') and player.y > 50 then
        player.y = player.y - 5
    elseif love.keyboard.isDown('s') and player.y < window_height - player.radius then
        player.y = player.y + 5
    end
end

love.draw = function()
    love.graphics.circle(
        "fill",
        player.x,
        player.y,
        player.radius
    )
end
