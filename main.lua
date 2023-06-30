love.load = function()
    player = {
        x = 100,
        y = 100,
        radius = 50,
        physics = {
            velocity = {
                x = 0,
                y = 0
            },
            gravity = 0.1,
            speed = 5
        }
    }
    window_width, window_height = love.graphics.getDimensions()
end

love.update = function()
    player.physics.velocity.x = 0

    if player.y < window_height - player.radius then
        player.physics.velocity.y = player.physics.speed
    else
        player.physics.velocity.y = 0
    end

    if love.keyboard.isDown('a') and player.x > 50 then
        player.physics.velocity.x = -player.physics.speed
    elseif love.keyboard.isDown('d') and player.x < window_width - player.radius then
        player.physics.velocity.x = player.physics.speed
    elseif love.keyboard.isDown('w') and player.y > 50 then
        player.physics.velocity.y = -player.physics.speed
    end

    player.x = player.x + player.physics.velocity.x
    player.y = player.y + player.physics.velocity.y
end

love.draw = function()
    love.graphics.circle(
        "fill",
        player.x,
        player.y,
        player.radius
    )
end
