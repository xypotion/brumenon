require "eventSetQueue"
require "events/actuation"

function love.load()
	print("BRUMENON")
	
	cellD = 40
	
	--init event system
	eventFrameLength = 0.05
	eventFrame = 0
	eventSetQueue = {}
	--TODO make queue bi-directional by (1) processing from the lowest index, even if it's negative, and (2) letting event sets be pushed onto the front
	
	testCounter = {actual = 0, shown = 0, max = 999}
	
	actors = {}
	actors.hero = {class = "hero"}
	
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
			-- if c.class then
				-- if c.class == "clear" then
					-- white()
				-- elseif c.class == "hero" then
				-- 	love.graphics.setColor(233, 233, 23)
				-- end
				
				love.graphics.rectangle("fill", 100 + y * cellD, 10 + x * cellD, 40, 40)
			-- else
				--no-op
			-- end
		end
	end
	
	--draw middle layer
	love.graphics.setColor(96, 48, 48, 255)
	for y, r in ipairs(field.middle) do
		for x, c in ipairs(r) do
			if c.class == "rock" then
				love.graphics.rectangle("fill", 100 + y * cellD, 10 + x * cellD, 36, 36)
			else
				--no-op
			end
		end
	end
	
	--draw sprites
	-- love.graphics.circle()	
	love.graphics.setColor(192, 192, 32, 255)
	for y, r in ipairs(field.sprites) do
		for x, c in ipairs(r) do
			if c.class == "hero" then
				--TODO
				--drawActor()
				
				love.graphics.circle("fill", 120 + y * cellD, 30 + x * cellD, 15)
				love.graphics.rectangle("fill", 105 + y * cellD, 15 + x * cellD, 30, 15)
			else
				--no-op
			end
		end
	end
	
	--draw upper field layer
	love.graphics.setColor(32, 192, 32, 128)
	for y, r in ipairs(field.high) do
		for x, c in ipairs(r) do
			if c.class == "leaves" then
				love.graphics.rectangle("fill", 115 + y * cellD, 10 + x * cellD, 25, 25)
				love.graphics.rectangle("fill", 100 + y * cellD, 25 + x * cellD, 25, 25)
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
	--END DEBUG ]]
	
	if key == "space" then
		queue(actuationEvent(testCounter, math.random(100)))
	end
end

------------------------------------------------------------------------------------------------------

function white()
	love.graphics.setColor(255, 255, 255, 255)
end

--copied directly from HDBS, but you will probably need something like this eventually!
-- function cellAt(y, x)
-- 	if stage.field[y] then
-- 		return stage.field[y][x]
-- 	else
-- 		return nil
-- 	end
-- end

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