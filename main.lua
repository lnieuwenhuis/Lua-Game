love.load = function()
    love.window.setTitle("Moon Invasion Defense")

    -- Player Variables
    player = {
        x = 100,
        y = 100,
        width = 40,
        height = 40,
        timer = 0,
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
    }

    -- Boss Variables
    boss = {
        x = 600,
        y = 500,
        width = 60,
        height = 60,
        timer = 0,
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
        projectile_timer = 0,
        projectile_timer_max = {
            projectile_one = 60,
            projectile_two = 50,
            projectile_three = 40
        },
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

        --Boss Projectile Movement
        for i, projectile in pairs(projectiles.boss) do
            if projectile.direction == 1 then
                projectile.x = projectile.x - 7
            elseif projectile.direction == 2 then
                projectile.x = projectile.x + 7
            end

            if projectile.x >= window_width or projectile.x <= 0 then
                table.remove(projectiles.boss, i)
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

        -- Timers
        player.timer = player.timer + 1
        boss.timer = boss.timer + 1

        if player.timer >= 200 then
            player.timer = 0
        end

        -- Movement Timers
        if boss.health >= 500 then
            -- Boss movement
            if boss.x >= window_width - boss.width or boss.x <= 0 then
                boss.x = boss.x
            elseif x_distance >= 146 and x_distance <= 154 then
                boss.x = boss.x
            elseif x_distance <= -155 then
                boss.x = boss.x - 2
            elseif x_distance >= 155 then
                boss.x = boss.x + 2
            elseif x_distance >= -145 and x_distance <= 0 then
                boss.x = boss.x + 1
            elseif x_distance <= 145 and x_distance >= 0 then
                boss.x = boss.x - 1
            end

            -- Boss jumps when player is above them
            if boss.physics.grounded and y_distance <= -160 then
                boss.physics.velocity.y = -boss.physics.jump_force
            end

            if boss.timer >= 300 then
                boss.timer = 0
            end
        elseif boss.health < 500 and boss.health >= 250 then
            -- Boss movement
            if boss.x >= window_width - boss.width or boss.x <= 0 then
                boss.x = boss.x
            elseif x_distance >= 146 and x_distance <= 154 then
                boss.x = boss.x
            elseif x_distance <= -155 then
                boss.x = boss.x - 2
            elseif x_distance >= 155 then
                boss.x = boss.x + 2
            elseif x_distance >= -145 and x_distance <= 0 then
                boss.x = boss.x + 1
            elseif x_distance <= 145 and x_distance >= 0 then
                boss.x = boss.x - 1
            end

            -- Boss jumps when player is above them
            if boss.physics.grounded and y_distance <= -160 then
                boss.physics.velocity.y = -boss.physics.jump_force
            end

            if boss.timer >= 200 then
                boss.timer = 0
            end
        elseif boss.health < 250 then
            -- Boss movement
            if boss.x >= window_width - boss.width or boss.x <= 0 then
                boss.x = boss.x
            elseif x_distance >= 146 and x_distance <= 154 then
                boss.x = boss.x
            elseif x_distance <= -155 then
                boss.x = boss.x - 2
            elseif x_distance >= 155 then
                boss.x = boss.x + 2
            elseif x_distance >= -145 and x_distance <= 0 then
                boss.x = boss.x + 1
            elseif x_distance <= 145 and x_distance >= 0 then
                boss.x = boss.x - 1
            end

            -- Boss jumps when player is above them
            if boss.physics.grounded and y_distance <= -160 then
                boss.physics.velocity.y = -boss.physics.jump_force
            end

            if boss.timer >= 100 then
                boss.timer = 0
            end
        end

        -- Projectile Timers
        boss.projectile_timer = boss.projectile_timer + 1
        if boss.health >= 500 then
            if boss.projectile_timer >= boss.projectile_timer_max.projectile_one then
                boss.projectile_timer = 0
                if x_distance <= 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 1
                        }
                    )
                elseif x_distance > 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 2
                        }
                    )
                end
            end
        elseif boss.health < 500 and boss.health >= 250 then
            if boss.projectile_timer >= boss.projectile_timer_max.projectile_two then
                boss.projectile_timer = 0
                if x_distance <= 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 1
                        }
                    )
                elseif x_distance > 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 2
                        }
                    )
                end
            end
        elseif boss.health < 250 then
            if boss.projectile_timer >= boss.projectile_timer_max.projectile_three then
                boss.projectile_timer = 0
                if x_distance <= 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 1
                        }
                    )
                elseif x_distance > 0 then
                    table.insert(
                        projectiles.boss,
                        {
                            x = boss.x,
                            y = boss.y + 25,
                            w = 20,
                            h = 3,
                            direction = 2
                        }
                    )
                end
            end
        end

        -- Boss Movement
        boss.x = boss.x + boss.physics.velocity.x
        boss.y = boss.y + boss.physics.velocity.y

        -- Resetting TPS
        accumulator = accumulator - tick_period
    end
    -- Getting FPS
    fps = love.timer.getFPS()

    -- Changing variables
    x_distance = player.x - boss.x
    y_distance = player.y - boss.y
end

love.draw = function()
    if boss.health > 0 and player.health > 0 then
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

        -- Draw Player Projectiles
        for i, projectile in pairs(projectiles.player) do
            love.graphics.rectangle(
                "fill",
                projectile.x,
                projectile.y,
                projectile.w,
                projectile.h
            )
        end

        love.graphics.setColor(128, 0, 128)
        -- Draw Boss Projectiles
        for i, projectile in pairs(projectiles.boss) do
            love.graphics.rectangle(
                "fill",
                projectile.x,
                projectile.y,
                projectile.w,
                projectile.h
            )
        end
        love.graphics.setColor(255, 255, 255)

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

        -- Drawing Debug Stats
        love.graphics.print(tostring(player.physics.grounded), 0, 15)
        love.graphics.print(tostring(boss.physics.grounded), 20, 15)

        love.graphics.print(fps)
        love.graphics.print((x_distance), 0, 50)
        love.graphics.print((y_distance), 0, 60)
        love.graphics.print(tostring(player.timer), 0, 30)
        love.graphics.print(tostring(boss.timer), 0, 40)
        love.graphics.print(tostring(#projectiles.player), 50, 15)
    elseif boss.health <= 0 then
        love.graphics.print("YOU WON!!", (window_width / 2) - 50)
        love.graphics.print("Press Enter to Replay...", (window_width / 2) - 90, 20)
    elseif player.health <= 0 then
        love.graphics.print("You lost...", (window_width / 2) - 50)
        love.graphics.print("Press Enter to Replay...", (window_width / 2) - 90, 20)
    end
end

-- Other love functions
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

    -- Reset game on Enter
    if key == "return" and (boss.health <= 0 or player.health <= 0) then
        boss.health = 780
        player.health = 100
        player.x = 100
        player.y = 100
        boss.x = 600
        boss.y = 500

        for i, projectile in pairs(projectiles.player) do
            table.remove(projectiles.player, i)
        end
        for i, projectile in pairs(projectiles.boss) do
            table.remove(projectiles.boss, i)
        end
    end

    -- End game when Escape is pressed
    if key == "escape" then
        love.event.quit()
    end
end
