push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
COMPUTER_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setTitle('Pong')
	math.randomseed(os.time())
	
	smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
	
	sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
	
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
	    fullscreen = false,
		resizable = true,
		vsync = true
	})

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	servingPlayer = 1
	
	player1Score = 0
	player2Score = 0
	
	player1computer = false
	player2computer = false
	
	impossibleMode = false
	
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	
	gameState = 'start'
end

function love.resize(w, h)
    push:resize(w,h)
end

function love.update(dt)
    -- player 1
	if player1computer == false then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
		end
	else
	    if impossibleMode == false then
	        if ball.x < VIRTUAL_WIDTH/2 - 2 then
                if ball.y - 10 < player1.y then
		            player1.dy = -COMPUTER_SPEED
		        elseif ball.y - 10> player1.y then
		            player1.dy = COMPUTER_SPEED
		        else
		            player1.dy = 0
		        end
            else
                player1.dy = 0
            end
		else
		    player1.y = ball.y - 10
		end
    end
	
	-- player 2
	if player2computer == false then
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
		end
	else
	    if impossibleMode == false then
	        if ball.x > VIRTUAL_WIDTH/2 - 2 then
                if ball.y - 10 < player2.y then
		            player2.dy = -COMPUTER_SPEED
		        elseif ball.y - 10 > player2.y then
		            player2.dy = COMPUTER_SPEED
		        else
		            player2.dy = 0
		        end
            else
                player2.dy = 0
            end
		else
		    player2.y = ball.y - 10
		end
    end
	
	if gameState == 'serve' then
	    ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
	elseif gameState == 'play' then
	    ball:update(dt)
		
		if ball:collides(player1) then
		    ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5
			
			if ball.dy < 0 then
			    ball.dy = -math.random(10, 150)
			else
			    ball.dy = math.random(10, 150)
			end
			
			sounds['paddle_hit']:play()
		end
		if ball:collides(player2) then
		    ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4
			
			if ball.dy < 0 then
			    ball.dy = -math.random(10, 150)
			else
			    ball.dy = math.random(10, 150)
			end
			
			sounds['paddle_hit']:play()
		end
		
		if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
			sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
			sounds['wall_hit']:play()
        end
		
		if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
			sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
			sounds['score']:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
	end
	
	player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
	elseif key == '1' and (gameState == 'start' or gameState == 'serve') then
	    if player1computer == false then
		    player1computer = true
		else 
		    player1computer = false
		end
	elseif key == '2' and (gameState == 'start' or gameState == 'serve') then
	    if player2computer == false then
		    player2computer = true
		else 
		    player2computer = false
		end
	elseif key == 'x' and (gameState == 'start' or gameState == 'serve') then
	    if impossibleMode == false then
		    impossibleMode = true
		else 
		    impossibleMode = false
		end
    end
end
	
function love.draw()
    push:apply('start')
	    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
        love.graphics.setFont(smallFont)	
		displayScore()
		
		if gameState == 'start' or gameState == 'serve' then
		    love.graphics.setFont(smallFont)
		    if player1computer == false then
			    love.graphics.setColor( 255, 0, 0, 255)
			    love.graphics.printf('Press 1 to use AI for Player 1', -130, 60, VIRTUAL_WIDTH, 'center')
			end
			if player2computer == false then
			    love.graphics.setColor( 0, 0, 255, 255)
			    love.graphics.printf('Press 2 to use AI for Player 2', 130, VIRTUAL_HEIGHT - 60, VIRTUAL_WIDTH, 'center')
			end
			if player1computer == true or player2computer == true then
			    if impossibleMode == false then
			        love.graphics.setColor( 255, 191, 0, 255)
				    love.graphics.printf('Press X to use Impossible Mode for AI', -130, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'center')
				else
				    love.graphics.setColor( 255, 0, 0, 255)
				    love.graphics.printf('Impossible Mode is ON', -165, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'center')
				end
			end
			love.graphics.setColor( 255, 255, 255, 255)
		end
		
	    if gameState == 'start' then
            love.graphics.printf('Welcome to Pong', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameState == 'serve' then
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameState == 'play' then
		elseif gameState == 'done' then
		    love.graphics.setFont(largeFont)
            love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        end
		
		--love.graphics.setColor( 255, 215, 0, 255)
		
		if player1computer == true then
		    love.graphics.setColor( 255, 0, 0, 255)
			player1:render()
		else
		    love.graphics.setColor( 255, 255, 255, 255)
		    player1:render()
		end
		
		love.graphics.setColor( 255, 255, 255, 255)
		
		if player2computer == true then
		    love.graphics.setColor( 0, 0, 255, 255)
			player2:render()
	    else
		    love.graphics.setColor( 255, 255, 255, 255)
	        player2:render()
	    end
		
		love.graphics.setColor( 255, 255, 255, 255)
		ball:render()
		
		displayFPS()
		
	push:apply('end')	
end

function displayScore()
    love.graphics.setFont(scoreFont)
	if player1computer == true then
		love.graphics.setColor( 255, 0, 0, 255)
	end
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
	if player2computer == true then
		    love.graphics.setColor( 0, 0, 255, 255)
	else
	        love.graphics.setColor( 255, 255, 255, 255)
	end
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallFont)
	love.graphics.setColor(0,255,0,255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end