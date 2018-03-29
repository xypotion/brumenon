function poseEvent(y, x, mf)
	local e = {
		class = "pose",
		y = y,
		x = x, 
		moveFrames = mf
	}
	
	return e
end

function poseEventProcessing(e)
	-- tablePrint(e)
	local f = pop(e.moveFrames)
	-- tablePrint(spriteAt(e.y, e.x))
		
	spriteAt(e.y, e.x).yOffset = f.yOffset
	spriteAt(e.y, e.x).xOffset = f.xOffset
	spriteAt(e.y, e.x).facing = f.facing
	
	if not peek(e.moveFrames) then
		e.finished = true
	end
end