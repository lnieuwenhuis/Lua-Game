love.load = function()
    love.window.setTitle("Moon Invasion Defense")

    -- Player Variables
    player = {
        x = 100,
        y = 100,
        width = 40,
        height = 40,
        physics = {
            velocity = {
                x = 0,
                y = 0
            },
            gravity = 0.5,
            speed = 5,
            jump_force = 15,
            grounded = false,
        }
    }

    -- Platform Variables
    platform_left = {
        x = 550,
        y = 400,
        width = 250,
        height = 20,
    }
    platform_right = {
        x = 0,
        y = 400,
        width = 250,
        height = 20,
    }

    -- Window Border Determining
    window_width, window_height = love.graphics.getDimensions()
end

love.update = function()
    -- Reset Player Velocity
    player.physics.velocity.x = 0

    -- Collisions With Platforms
    if player.y >= window_height - player.height or (
            player.physics.velocity.y >= 0
            and player.x + player.width > platform_left.x
            and player.x < platform_left.x + platform_left.width
            and player.y + player.height > platform_left.y
            and player.y + player.height - 1 < platform_left.y + platform_left.height
        ) or (
            player.physics.velocity.y >= 0
            and player.x + player.width > platform_right.x
            and player.x < platform_right.x + platform_right.width
            and player.y + player.height > platform_right.y
            and player.y + player.height - 1 < platform_right.y + platform_right.height
        ) then
        player.physics.velocity.y = 0
        player.physics.grounded = true
    else
        player.physics.velocity.y = player.physics.velocity.y + player.physics.gravity
        player.physics.grounded = false
    end

    -- Platform Clipping Hotfix
    if player.y >= window_height - player.height and player.physics.grounded then
        player.y = window_height - player.height
    elseif player.y >= platform_left.y - player.height - 1 and player.physics.grounded then
        player.y = platform_left.y - player.height + 1
    end

    -- Key Mapping For Movement
    if love.keyboard.isDown('space') and player.physics.grounded then
        player.physics.velocity.y = -player.physics.jump_force
    elseif love.keyboard.isDown('d') and love.keyboard.isDown('a') then
        player.physics.velocity.x = 0
    elseif love.keyboard.isDown('d') and player.x < window_width - player.height then
        player.physics.velocity.x = player.physics.speed
    elseif love.keyboard.isDown('a') and player.x > 0 then
        player.physics.velocity.x = -player.physics.speed
    end

    -- Player Movement
    player.x = player.x + player.physics.velocity.x
    player.y = player.y + player.physics.velocity.y

    -- Getting FPS
    fps = love.timer.getFPS()
end

love.draw = function()
    -- Drawing Player
    love.graphics.rectangle(
        "fill",
        player.x,
        player.y,
        player.width,
        player.height
    )

    -- Drawing Platforms
    love.graphics.rectangle(
        "fill",
        platform_left.x,
        platform_left.y,
        platform_left.width,
        platform_left.height
    )
    love.graphics.rectangle(
        "fill",
        platform_right.x,
        platform_right.y,
        platform_right.width,
        platform_right.height
    )

    -- Drawing If Player is Grounded and FPS
    love.graphics.print(tostring(player.physics.grounded), 0, 15)
    love.graphics.print(fps)
end
