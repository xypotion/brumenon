--move frame = {pose, yOffset, xOffset, facing}

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


-------------------------------------------------------------

function selfPoseEvent(args)
	local e = {
		class = "selfPose",
		actor = args.actor,
		poseFrames = args.poseFrames
	}
	
	return e
end

function selfPoseEventProcessing(e)
	local f = pop(e.poseFrames)
	
	actors[e.actor].facing = f.facing
	actors[e.actor].yOffset = f.yOffset
	actors[e.actor].xOffset = f.xOffset
	
	if not peek(e.poseFrames) then
		e.finished = true
	end
end