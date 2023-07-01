love.load = function()
    love.window.setTitle("Moon Invasion Defense")
    player = {
        x = 100,
        y = 100,
        radius = 40,
        physics = {
            velocity = {
                x = 0,
                y = 0
            },
            gravity = 0.4,
            speed = 5,
            jump_force = 15,
            grounded = false,
        }
    }
    window_width, window_height = love.graphics.getDimensions()
end

love.update = function()
    player.physics.velocity.x = 0

    if player.y < window_height - player.radius then
        player.physics.velocity.y = player.physics.velocity.y + player.physics.gravity
        player.physics.grounded = false
    else
        player.physics.velocity.y = 0
        player.physics.grounded = true
    end

    if love.keyboard.isDown('space') and player.y > player.radius and player.physics.grounded then
        player.physics.velocity.y = -player.physics.jump_force
    elseif love.keyboard.isDown('d') and player.x < window_width - player.radius then
        player.physics.velocity.x = player.physics.speed
    elseif love.keyboard.isDown('a') and player.x > player.radius then
        player.physics.velocity.x = -player.physics.speed
    end
    player.x = player.x + player.physics.velocity.x
    player.y = player.y + player.physics.velocity.y

    fps = love.timer.getFPS()
end

love.draw = function()
    love.graphics.circle(
        "fill",
        player.x,
        player.y,
        player.radius
    )
    love.graphics.print(tostring(player.physics.grounded), 0, 15)
    love.graphics.print(fps)
end
