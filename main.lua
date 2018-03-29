require "eventSetQueue"

require "events/actuation"
require "events/cellOp"
require "events/pose"

function love.load()
	print("BRUMENON")
	
	cellD = 40
	
	--init event system
	eventFrameLength = 0.025
	eventFrame = 0
	eventSetQueue = {}
	--TODO make queue bi-directional by (1) processing from the lowest index, even if it's negative, and (2) letting event sets be pushed onto the front
	
	testCounter = {actual = 0, shown = 0, max = 999}
	
	actors = {}
	actors.hero = {class = "hero", facing = "s", xOffset = 0, yOffset = 0}
	
	--initialize field
	field = {low = {}, middle = {}, sprites = {}, high = {}}
	field.low = {}
	for i = 1, 10 do
		field.low[i] = {}
		field.middle[i] = {}
		field.sprites[i] = {}
		field.high[i] = {}
		for j = 1, 10 do
			field.low[i][j] = {class = "clear", collide = false}
			field.middle[i][j] = {class = "clear", collide = false}
			field.sprites[i][j] = {class = "clear"}
			field.high[i][j] = {class = "clear"}
		end
	end
	
	field.sprites[2][2] = actors.hero
	
	field.middle[8][9] = {class = "rock", collide = true}
	field.middle[9][8] = {class = "rock", collide = true}
	field.middle[9][9] = {class = "rock", collide = true}
	
	field.high[2][8] = {class = "leaves"}
	field.high[3][9] = {class = "leaves"}
	field.high[8][2] = {class = "leaves"}
	field.high[9][3] = {class = "leaves"}
end

function love.update(dt)	
	--process events on a set interval
	eventFrame = eventFrame + dt
	if eventFrame >= eventFrameLength then
		processEventSets(dt)
		eventFrame = eventFrame % eventFrameLength
	end
	
	if inputLevel == "normal" then
		if love.keyboard.isDown("w") then
			heroImpetus(-1, 0)
			actors.hero.facing = "n"
		elseif love.keyboard.isDown("s") then
			heroImpetus(1, 0)
			actors.hero.facing = "s"
		elseif love.keyboard.isDown("a") then
			heroImpetus(0, -1)
			actors.hero.facing = "w"
		elseif love.keyboard.isDown("d") then
			heroImpetus(0, 1)
			actors.hero.facing = "e"
		end
	end
end

function love.draw()
	white()
	
	--canvas shit TODO
	
	--draw test stuff
	love.graphics.print(testCounter.shown, 10, 10)
	
	--draw lower field layer
	love.graphics.setColor(32, 32, 32, 255)
	for y, r in ipairs(field.low) do
		for x, c in ipairs(r) do
			love.graphics.rectangle("fill", 10 + x * cellD, 100 + y * cellD, 40, 40)
		end
	end
	
	--draw middle layer
	love.graphics.setColor(96, 48, 48, 255)
	for y, r in ipairs(field.middle) do
		for x, c in ipairs(r) do
			if c.class == "rock" then
				--TODO drawTile() -- will be used for all 3 non-sprite layers, pulling from chipset
				love.graphics.rectangle("fill", 12 + x * cellD, 102 + y * cellD, 36, 36)
			else
				--no-op
			end
		end
	end
	
	--draw sprites
	love.graphics.setColor(192, 192, 32, 255)
	for y, r in ipairs(field.sprites) do
		for x, c in ipairs(r) do
			if c.class == "hero" then
				drawActor(y, x, c)
			else
				--no-op
			end
		end
	end
	
	--draw upper field layer
	love.graphics.setColor(32, 96, 32, 192)
	for y, r in ipairs(field.high) do
		for x, c in ipairs(r) do
			if c.class == "leaves" then
				love.graphics.rectangle("fill", 10 + x * cellD, 115 + y * cellD, 25, 25)
				love.graphics.rectangle("fill", 25 + x * cellD, 100 + y * cellD, 25, 25)
			else
				--no-op
			end
		end
	end
	
end

function love.keypressed(key)
	-- [[ DEBUG
	if key == "escape" then
		--merry quitmas
		love.event.quit()
	end
	if key == "h" then
		print(locateHero())
	end
	if key == "space" then
		queue(actuationEvent(testCounter, math.random(100)))
	end
	--END DEBUG ]]
end

------------------------------------------------------------------------------------------------------

function drawActor(y, x, actor)
	love.graphics.circle("fill", 30 + x * cellD + actor.xOffset, 120 + y * cellD + actor.yOffset, 15)
	
	if actor.facing == "s" then
		love.graphics.rectangle("fill", 15 + x * cellD + actor.xOffset, 105 + y * cellD + actor.yOffset, 30, 15)
	elseif actor.facing == "n" then
		love.graphics.rectangle("fill", 15 + x * cellD + actor.xOffset, 120 + y * cellD + actor.yOffset, 30, 15)
	elseif actor.facing == "e" then
		love.graphics.rectangle("fill", 15 + x * cellD + actor.xOffset, 105 + y * cellD + actor.yOffset, 15, 30)
	elseif actor.facing == "w" then
		love.graphics.rectangle("fill", 30 + x * cellD + actor.xOffset, 105 + y * cellD + actor.yOffset, 15, 30)
	end
end

function heroImpetus(dy, dx)
	local y, x = locateHero()
	
	--see what lies ahead
	local destClass = nil
	if spriteAt(y + dy, x + dx) then
		destClass = cellAt(y + dy, x + dx, "middle").class
		-- destClass = spriteAt(y + dy, x + dx).class --TODO also this, but not that simple
	else
		--seems like you're trying to move off the grid, so...
		return
	end
	
	-- print(destClass)
	
	--move
	if destClass == "clear" then
		heroMove(y, x, dy, dx)
	end
end

--TODO actorMove()?
function heroMove(y, x, dy, dx)
	local ty, tx = y + dy, x + dx
	
	local facing = ""
	if spriteAt(ty, tx).facing then facing = spriteAt(ty, tx).facing end
	if dy < 0 then facing = "n" end
	if dy > 0 then facing = "s" end
	if dx < 0 then facing = "w" end
	if dx > 0 then facing = "e" end

	local moveFrames = {
		{pose = "idle", yOffset = dy * -30, xOffset = dx * -30, facing = facing},
		{pose = "idle", yOffset = dy * -20, xOffset = dx * -20, facing = facing},
		{pose = "idle", yOffset = dy * -10, xOffset = dx * -10, facing = facing},
		{pose = "idle", yOffset = 0, xOffset = 0, facing = facing},
	}

	--queue pose and cell ops
	queueSet({
		cellOpEvent(ty, tx, actors.hero),
		cellOpEvent(y, x, clear()),
		poseEvent(ty, tx, moveFrames)
	})
	
	processNow()
end

function locateHero()	
	for y = 1, 10 do
		for x = 1, 10 do
			if field.sprites[y][x].class == "hero" then
				return y, x
			end
		end
	end
	
	return nil, nil
end

function clear()
	return {class = "clear"}
end

------------------------------------------------------------------------------------------------------

function white()
	love.graphics.setColor(255, 255, 255, 255)
end

-- copied directly from HDBS!
function cellAt(y, x, layer)
	if field[layer][y] then
		return field[layer][y][x]
	else
		return nil
	end
end

--maybe not actually necessary? not sure. TODO
function spriteAt(y, x)
	return cellAt(y, x, "sprites")
end

function peek(q)
	return q[1]
end

function pop(q)
	local item = q[1]
	
	for i = 2, table.getn(q) do
		q[i - 1] = q[i]
	end
	
	q[table.getn(q)] = nil

	return item
end

function push(q, item)
	table.insert(q, item)
end

--TODO :)
function frontPush(q, item)
end

--an old helper function i made in 2014 :)
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			print(offset.."sub-table ["..k.."]:")
			tablePrint(v, offset.."  ")
		else
			print(offset.."["..k.."] = "..tostring(v))
		end
	end	
end