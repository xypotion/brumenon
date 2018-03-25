require "eventSetQueue"
require "queueProcessing"

function love.load()
	print("BRUMENON")
	
	cellD = 40
	
	--init event system
	eventFrameLength = 0.05
	eventFrame = 0
	eventSetQueue = {}
	--TODO make queue bi-directional by (1) processing from the lowest index, even if it's negative, and (2) letting event sets be pushed onto the front
	
	testCounter = {actual = 0, shown = 0, max = 999}
	
	field  = {}
	for i = 1, 10 do
		field[i] = {}
		for j = 1, 10 do
			field[i][j] = {class = "clear"}
		end
	end
	
	field[2][2] = {class = "hero"}
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
	
	--canvas shit
	
	--draw test stuff
	love.graphics.print(testCounter.shown, 10, 10)
	
	--draw field
	for y, r in ipairs(field) do
		for x, c in ipairs(r) do
			if c.class then
				if c.class == "clear" then
					white()
				elseif c.class == "hero" then
					love.graphics.setColor(233, 233, 23)
				end
				
				love.graphics.rectangle("fill", 100 + y * cellD, 10 + x * cellD, 36, 36)
			else
				--no-op
			end
		end
	end
	
	--draw player
	
end

function love.keypressed(key)
	--DEBUG
	--[ [
	if key == "escape" then
		--merry quitmas
		love.event.quit()
	end
	--]]
	
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