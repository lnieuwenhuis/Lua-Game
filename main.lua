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
        },
        health = 100,
        dead = false,
    }

    -- Boss Variables
    boss = {
        x = 600,
        y = 500,
        width = 60,
        height = 60,
        physics = {
            velocity = {
                x = 0,
                y = 0,
            },
            gravity = 0.5,
            speed = 5,
            jump_force = 15,
            grounded = false,
        },
        health = 780,
        dead = false,
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

    -- Projectiles table
    projectiles = {
        boss = {

        },
        player = {

        }
    }

    -- Window Border Determining
    window_width, window_height = love.graphics.getDimensions()

    -- Setting up Physics Capping
    tick_period = 1 / 60
    accumulator = 0.0
end

love.update = function(dt)
    accumulator = accumulator + dt
    -- Caps Physics to 60 TPS
    if accumulator >= tick_period then
        -- Reset Player and Boss Velocity
        player.physics.velocity.x = 0
        boss.physics.velocity.x = 0

        -- Player Collisions With Platforms and Ground
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

        -- Boss Collisions with Platforms and Ground
        if boss.y >= window_height - boss.height or (
                boss.physics.velocity.y >= 0
                and boss.x + boss.width > platform_left.x
                and boss.x < platform_left.x + platform_left.width
                and boss.y + boss.height > platform_left.y
                and boss.y + boss.height - 1 < platform_left.y + platform_left.height
            ) or (
                boss.physics.velocity.y >= 0
                and boss.x + boss.width > platform_right.x
                and boss.x < platform_right.x + platform_right.width
                and boss.y + boss.height > platform_right.y
                and boss.y + boss.height - 1 < platform_right.y + platform_right.height
            ) then
            boss.physics.velocity.y = 0
            boss.physics.grounded = true
        else
            boss.physics.velocity.y = boss.physics.velocity.y + boss.physics.gravity
            boss.physics.grounded = false
        end

        -- Platform Clipping Hotfix
        if player.y >= window_height - player.height and player.physics.grounded then
            player.y = window_height - player.height
        elseif player.y >= platform_left.y - player.height - 1 and player.physics.grounded then
            player.y = platform_left.y - player.height + 1
        end
        -- Also for the boss
        if boss.y >= window_height - boss.height and boss.physics.grounded then
            boss.y = window_height - boss.height
        elseif boss.y >= platform_left.y - boss.height - 1 and boss.physics.grounded then
            boss.y = platform_left.y - boss.height + 1
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
        -- Boss Movement
        boss.x = boss.x + boss.physics.velocity.x
        boss.y = boss.y + boss.physics.velocity.y

        -- Player Projectile Movement
        for i, projectile in pairs(projectiles.player) do
            if projectile.direction == 1 then
                projectile.x = projectile.x - 7
            elseif projectile.direction == 2 then
                projectile.x = projectile.x + 7
            end

            if projectile.x >= window_width or projectile.x <= 0 then
                table.remove(projectiles.player, i)
            end
        end

        -- Boss hit by Projectile
        for i, projectile in pairs(projectiles.player) do
            if (projectile.x > boss.x and projectile.x < boss.x + boss.width)
                and (projectile.y > boss.y and projectile.y < boss.y + boss.height) then
                boss.health = boss.health - 7.8
                table.remove(projectiles.player, i)
            end
        end

        -- Player hit by Projectiles
        for i, projectile in pairs(projectiles.boss) do
            if (projectile.x > player.x and projectile.x < player.x + player.width)
                and (projectile.y > player.y and projectile.y < player.y + player.height) then
                player.health = player.health - 10
                table.remove(projectiles.boss, i)
            end
        end

        -- Resetting TPS
        accumulator = accumulator - tick_period
    end
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

    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle(
        "fill",
        boss.x,
        boss.y,
        boss.width,
        boss.height
    )
    love.graphics.setColor(255, 255, 255)

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

    -- Draw Projectiles
    for i, projectile in pairs(projectiles.player) do
        love.graphics.rectangle(
            "fill",
            projectile.x,
            projectile.y,
            projectile.w,
            projectile.h
        )
    end

    -- Drawing Boss health bar
    love.graphics.rectangle(
        "fill",
        10,
        10,
        780,
        22
    )
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle(
        "fill",
        10,
        10,
        boss.health,
        20
    )
    love.graphics.setColor(255, 255, 255)

    -- Drawing Player health bar
    love.graphics.rectangle(
        "fill",
        10,
        50,
        300,
        17
    )
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle(
        "fill",
        10,
        50,
        player.health * 3,
        15
    )
    love.graphics.setColor(255, 255, 255)

    -- Drawing If Player is Grounded, FPS and number of Projectiles
    love.graphics.print(tostring(player.physics.grounded), 0, 15)
    love.graphics.print(fps)
    love.graphics.print(tostring(#projectiles.player), 50, 15)
end

function love.keypressed(key)
    -- Check for left arrow press
    if key == "left" then
        -- Insert into Projectiles table
        table.insert(
            projectiles.player,
            {
                x = player.x,
                y = player.y,
                w = 20,
                h = 3,
                direction = 1
            }
        )
    end

    -- Check for right arrow press
    if key == "right" then
        -- Insert into Projectiles table
        table.insert(
            projectiles.player,
            {
                x = player.x,
                y = player.y,
                w = 20,
                h = 3,
                direction = 2
            }
        )
    end

    -- End game when Escape is pressed
    if key == "escape" then
        love.event.quit()
    end
end
