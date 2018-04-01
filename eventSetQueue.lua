--basic mechanism called by love.update() that processes events sets in the queue
function processEventSets(dt)
	--block input during processing if there are any events, otherwise allow input and break
	if peek(eventSetQueue) then 
		inputLevel = "none"
		-- print("none!")
	else
		inputLevel = "normal"
		return
	end
	
	local es = peek(eventSetQueue)
	local numFinished = 0
	
	--process them all
	for k, e in pairs(es) do
		--if not already finished, process this event 
		if not e.finished then
			-- print("processing "..e.class)
			if e.class then
				if e.class == "function" then
					-- print("...calling "..e.func)
					_G[e.func](e.arg1)
					e.finished = true
				else
					-- print(e.class.."EventProcessing")
					_G[e.class.."EventProcessing"](e)
				end
			else
				print("you made another event without a class, dummy")
			end
		end
				
		--tally finished events in set
		if e.finished then
			numFinished = numFinished + 1
		end
	end
	
	--pop event set if all finished
	if numFinished == #es then
		pop(eventSetQueue)
	end
end

--add one event to the event set queue by wrapping it in a table
function queue(event)
	queueSet({event})
end

--add a set of events to the queue
function queueSet(eventSet)
	push(eventSetQueue, eventSet)
end

--force queue set to be processed immediately, not at next scheduled interval. should start normally again after this
function processNow()
	eventFrame = eventFrameLength
end

--for when all that's provided is a table with the event type + its args (or a table of such tables)
function queueSetFromScript(es)
	for k, e in ipairs(es) do
		print("queueing ", e.class)
		es[k] = _G[e.class.."Event"](e.args)
	end
	
	queueSet(es)
end

------------------------------------------------------------------------------------------------------

-- function gameStateEvent(v, to)
-- 	local e = {
-- 		class = "gameState",
-- 		variable = v,
-- 		value = to
-- 	}
--
-- 	return e
-- end
--
-- function cellOpEvent(y, x, thing)
-- 	local e = {
-- 		class = "cellOp",
-- 		y = y,
-- 		x = x,
-- 		payload = thing
-- 	}
--
-- 	return e
-- end



-- --basically just for applying and removing sticks
-- function statusEvent(ey, ex, s)
-- 	local e = {
-- 		class = "status",
-- 		y = ey,
-- 		x = ex,
-- 		status = s
-- 	}
--
-- 	return e
-- end
--
-- --for making battle entities change poses and/or move around
-- function poseEvent(y, x, f)
-- 	local e = {
-- 		class = "pose",
-- 		y = y, --location of drawable entity (cell contents)
-- 		x = x,
-- 		frames = f	--frames = { {pose, yOffset, xOffset}s }
-- 	}
--
-- 	return e
-- end
--
-- --for fancy battle graphics. automatically targets cells' invisible animation overlays
-- function animEvent(y, x, f)--fx, f)
-- 	local e = {
-- 		class = "anim",
-- 		y = y,		--location of drawable entity (cell overlay)
-- 		x = x,
-- 		frames = f		--frames = { quad pointers (row on effects sheet) }
-- 	}
--
-- 	return e
-- end
--
-- --for starting or stopping sounds
-- function soundEvent(name)
-- 	local e = {
-- 		class = "sound",
-- 		soundName = name
-- 		--repeatTimes TODO probably the best way to do a good gluttony sound
-- 	}
--
-- 	return e
-- end
--
-- function bgmEvent(nowName, nextName)
-- 	local e = {
-- 		class = "bgm",
-- 		current = nowName,
-- 		next = nextName
-- 	}
--
-- 	return e
-- end
--
-- function bgmFadeEvent()
-- 	local e = {
-- 		class = "bgmFade"
-- 	}
--
-- 	return e
-- end
--
-- --for changing backgrounds
-- function bgEvent(bg, time)
-- 	local e = {
-- 		class = "bg",
-- 		graphic = bg, --night, day, title, etc.; all named graphics to fade into background layer
-- 		time = time or 0.5 --seconds to draw out fade
-- 	}
--
-- 	return e
-- end
--
-- --for changing backgrounds
-- function waitEvent(time)
-- 	local e = {
-- 		class = "wait",
-- 		time = time or 0.5 --seconds to draw out fade
-- 	}
--
-- 	return e
-- end
--
-- function fadeOutEvent(time)
-- 	local e = {
-- 		class = "fadeOut",
-- 		time = time or 0.25
-- 	}
--
-- 	return e
-- end
--
-- function fadeInEvent(time)
-- 	local e = {
-- 		class = "fadeIn",
-- 		time = time or 0.25
-- 	}
--
-- 	return e
-- end
--
-- --for overlays and such. text or image flies up from the bottom & is then dismissed either after a wait or a keypress
-- function screenEvent(text, kr, bd, im) --TODO should actually be an overlay graphic's name, but just text for now
-- 	local e = {
-- 		class = "screen",
-- 		text = text,
-- 		keypressRequired = kr,
-- 		backdrop = bd,
-- 		image = im
-- 	}
--
-- 	return e
-- end
--
-- --when processed, causes a function to be called with args
-- --is this the worst thing i've done yet? or should i have done this a long time ago?
-- function functionEvent(func, arg1)
-- 	local e = {
-- 		class = "function",
-- 		func = func,
-- 		arg1 = arg1, --messy, messy, messy. oh, well.
-- 	}
--
-- 	return e
-- end

------------------------------------------------------------------------------------------------------