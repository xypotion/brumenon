--force queue set to be processed immediately, not at next scheduled interval. should start normally again after this
function processNow()
	eventFrame = eventFrameLength
end

------------------------------------------------------------------------------------------------------

function processEventSets(dt)
	--block input during processing if there are any events, otherwise allow reenable input and break
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
		--TODO this stack of ifs is just awfs. DO SOMETHIIING EEHHHH
		if not e.finished then
			-- print("processing "..e.class)
			
			if e.class == "function" then
				-- print("...calling "..e.func)
				_G[e.func](e.arg1)
				e.finished = true
			end
			--
			-- if e.class == "gameState" then
			-- 	processGameStateEvent(e)
			-- end
			--
			-- if e.class == "cellOp" then
			-- 	processCellOpEvent(e)
			-- end
			--
			if e.class == "actuation" then
				processActuationEvent(e)
			end
			--
			-- if e.class == "status" then
			-- 	processHeroStatusEvent(e)
			-- end
			--
			-- if e.class == "pose" then
			-- 	processPoseEvent(e)
			-- end
			--
			-- if e.class == "anim" then
			-- 	processAnimEvent(e)
			-- end
			--
			-- if e.class == "sound" then
			-- 	processSoundEvent(e)
			-- end
			--
			-- if e.class == "bgm" then
			-- 	processBgmEvent(e)
			-- end
			--
			-- if e.class == "bgmFade" then
			-- 	processBgmFadeEvent(e)
			-- end
			--
			-- if e.class == "bg" then
			-- 	processBgEvent(e)
			-- end
			--
			-- if e.class == "wait" then
			-- 	processWaitEvent(e)
			-- end
			--
			-- if e.class == "fadeIn" then
			-- 	processFadeInEvent(e)
			-- end
			--
			-- if e.class == "fadeOut" then
			-- 	processFadeOutEvent(e)
			-- end
			--
			-- if e.class == "screen" then
			-- 	processScreenEvent(e)
			-- end
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

function processActuationEvent(e)
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