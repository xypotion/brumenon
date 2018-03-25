--force queue set to be processed immediately, not at next scheduled interval. should start normally again after this
function processNow()
	eventFrame = eventFrameLength
end

------------------------------------------------------------------------------------------------------

function processEventSets(dt)
	--block input during processing if there are any events, otherwise allow input and break
	if peek(eventSetQueue) then 
		inputLevel = "none"
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
					-- processActuationEvent(e)
					_G[e.class.."Processing"](e)
				end
			end
		end
				
		--tally finished events in set
		if e.finished then
			numFinished = numFinished + 1
		end
	end
	
	--pop event if all finished
	if numFinished == #es then
		pop(eventSetQueue)
	end
end

------------------------------------------------------------------------------------------------------

function actuationProcessing(e)
	-- --play sound
	-- if e.delta > 0 and e.counter.posSound then
	-- 	sfx[e.counter.posSound]:stop()
	-- 	sfx[e.counter.posSound]:play()
	-- elseif e.delta < 1 and e.counter.negSound then
	-- 	sfx[e.counter.negSound]:stop()
	-- 	sfx[e.counter.negSound]:play()
	-- end
	
	--decrement shown and increment delta OR vice-versa, as long as shown is not already at max or 0
	if e.delta > 0 and e.counter.shown < e.counter.max then
		e.counter.shown = e.counter.shown + 1
		e.delta = e.delta - 1
	elseif e.delta < 0 and e.counter.shown > 0 then
		e.counter.shown = e.counter.shown - 1
		e.delta = e.delta + 1
	end
	
	--finished if delta is depleted OR shown is at max or shown is at 0
	if e.delta == 0 or e.counter.shown >= e.counter.max or e.counter.shown <= 0 then
		e.finished = true
	end
end