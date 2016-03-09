function love.load()

    time = 0  --basic time for controlling shrinking and stopping of ball as long as theres no input
	time2= 0

	--generate a random start value for time threshhold (when to start growing the ball)
	--this might need more modifiers
	--the second variable should grow so there will be more difference and less expectability
	timemod1 = 1
	timemod2 = 3
	timethreshhold = math.random()+math.random(timemod1,timemod2)


	--control variables
	distance = 0
	stopped = 0
	--control speed of movement and speed of ball
	speedfactor = 1
	speedfactor2 = 0.01
	--control level to change speed of growth for ball
	levelstep = 1
	level = 1
	
	--scoring stuff
	--as of now: Score = distance/100 + previous ball size (accumulated for all previous balls)
	score = 0

	mousedown = "none"

	--screen switches
	menu = 1 --0 = game, 1 = mainmenu 2 = ?? etc.
	gameover = 0
	game_quit = 0
	wait = 10 --time to wait before allowing next scene triggers to run
	
	--problem: lua has no real object-oriented structures
	--so have to initialize clickable objects as tables i guess...
	--format: "img", "x", "y", "width", "height"
	--CAN ARRAYS BE STORED IN ARRAYS?? THATS A COMMON FEATURE NOWADAYS ANYWAY

	--menu objects
	--new game button
	ngbutton = {}
	ngbutton["img"]=love.graphics.newImage("gfx/menu/newgame.png")
	ngbutton["x"]=300
	ngbutton["y"]=200
	ngbutton["width"]=ngbutton["img"]:getWidth()
	ngbutton["height"]=ngbutton["img"]:getHeight()
	
	--quit game button
	qgbutton = {}
	--there is a trouble with this???
	qgbutton["img"]=love.graphics.newImage("gfx/menu/quitgame.png")
	qgbutton["x"]=300
	qgbutton["y"]=300
	qgbutton["width"]=320
	qgbutton["height"]=100

	--resource inits
	curball = 1
	prevball = 1
	resetball = 0
	pallot = {}
	pallot.img = {}
	for i=1,10 do
		pallot.img[i] = love.graphics.newImage("gfx/bead1.png")
	end
	pallot.x = {}
	pallot.y = {}
	for i=1,10 do	--send the balls back to the left of the screen
		pallot.x[i] = -5000
		pallot.y[i] = 0
	end
	pallot.xoffset = {}
	for i=1,10 do
		pallot.xoffset[i] = 0
	end

	pallot.koko = {}
	for i=1,10 do
		pallot.koko[i] = 0.1
	end
	pallot.img[1] = love.graphics.newImage("gfx/bead1.png")
	
	--load menu gfx
	ngbutton[1]=love.graphics.newImage("gfx/menu/newgame.png")
	qgbutton=love.graphics.newImage("gfx/menu/quitgame.png")

	background=love.graphics.newImage("gfx/background/aero.png") --load background
	
	beads1music = love.audio.newSource("bgm/pianotaters.mp3") --load bgm's
	gameovermusic = love.audio.newSource("bgm/gameover.mp3")
	
	--debugging stuff
	debugballsizex = 0
	debugballsizey = 0
	prevballrightside = 0
	debugmode = 0
end

function love.update(dt) --main loop
	mousedown = love.mouse.isDown("l")
	--menu navigation
	if menu == 1 then
		--clicked_on_something()
		--gotta make a function for this, man...
		if clicked_on_something(ngbutton)==true then menu = 0 end
		--if clicked_on_something(qgbutton)==true then game_quit = 1 end
	end
	
	if gameover == 0 and menu == 0 then
		

		time = time + 2*dt
		if time > timethreshhold then --stop the movement
			stopped = 1
		end
		--grow the ball while movement is stopped
		if stopped == 1 then
			if resetball == 1 then
				pallot.koko[curball] = 0.01
				resetball = 0
				beads1music:setPitch(1.0)
			end
			pallot.xoffset[curball] = 0
			--if a ball is 256,256 then count the scale
			--and position ball middle point accordingly
			--ballpos = ballsize*scale
			pallot.koko[curball] = pallot.koko[curball] + speedfactor2
			pallot.x[curball] = 400-(128*pallot.koko[curball])
			pallot.y[curball] = 300-(128*pallot.koko[curball])
			--let's make a debug function to calc ball size
			debugballsizex = 256*pallot.koko[curball]
			debugballsizey = 256*pallot.koko[curball]
			--lets calculate IF curball's left side touches the right side of prev ball
			--x is counted from left side, so we just add prev balls x with size((pallot.x[curball-1]+(256*scale)) to get right side
			--remember to check that we wont go out of array index bounds (less than 0)
			prevball = curball-1
			if prevball < 1 then prevball = 10 end
			prevballrightside = pallot.x[prevball]+(256*pallot.koko[prevball])
			if prevballrightside > pallot.x[curball] then
				gameover = 1
			end
			
		end

		--stuff to do when curball is growing and user press mouse
		if mousedown and stopped == 1 then
			--reset the time, generate a new stop point
			time=0
			timethreshhold = math.random()+math.random(timemod1,timemod2)
			speedfactor = speedfactor + 1
			levelstep = levelstep + 1
			if levelstep > 10 then
				speedfactor2 = speedfactor2 + 0.01
				level = level + 1
			end
			stopped = 0
			mousedown = false
			if curball < 10 then
				curball = curball + 1
			end
			if curball == 10 then
				curball = 1
			end
		end
		if stopped == 0 then	--grow the distance when the line is not stopped (aka we are moving forward)
			distance = distance + speedfactor
			resetball = 1
			for i=1,10 do
				pallot.x[i] = pallot.x[i] - speedfactor
			end
		end
		beads1music:play()
	end
	
	--what happens when game ends?
	if gameover == 1 then
		beads1music:stop()
		gameovermusic:play()
		if wait > 0 and mousedown == false then
			wait = wait - 1
		end
		if love.mouse.isDown("l") and wait < 1 then
			love.event.quit()
		end
	end
	mousedown = false
	
	--this game just became a spiderman thread
	if game_quit == 1 then
		beads1music:stop()
		love.event.quit()
	end
end

function love.draw()
	--drawing stuff obviously
	--mainmenu going on stuff
	if menu == 1 then
		love.graphics.draw(ngbutton["img"], ngbutton["x"], ngbutton["y"])
		--love.graphics.draw(qgbutton["img"], qgbutton["x"], qgbutton["y"])
	end
	--normal game going on stuff
	if gameover == 0 and menu == 0 then
		love.graphics.draw(background, 0, 0)
		if debugmode == 1 then
			love.graphics.print(distance, 20,40)
			love.graphics.print(pallot.x[curball], 20, 80)
			love.graphics.print(prevballrightside, 20, 160)
			love.graphics.print(pallot.x[prevball], 20, 180)
		end
		love.graphics.line(400-distance, 300, 400, 300)
		for i=1,10 do
			love.graphics.draw(pallot.img[i], pallot.x[i], pallot.y[i],0,pallot.koko[i])
		end
	end

	if gameover == 1 then
		love.graphics.print("Game Over!", 400,300)
		love.graphics.print("Press mouse to quit", 400,320)
	end
end

--this function gets the coordinates of all relevant objects that can be clicked
--menu items, powerups, etc.
--it is probably the most sensical to actually get the items we want to check for, instead
--of supplying coordinates by hand every time when wanting to check for clicks
function clicked_on_something(objectname)
	local ms_x, ms_y = love.mouse.getPosition()
	local ax = objectname["x"]
	local ay = objectname["y"]
	local bx = objectname["width"]
	local by = objectname["height"]

	--check according to previous variables
	if ms_x > ax 
		and ms_x < ax + bx
		and ms_y > ay
		and ms_y < ay + by
		and love.mouse.isDown("l")==true then
		return true
	else
		return false
	end
end
