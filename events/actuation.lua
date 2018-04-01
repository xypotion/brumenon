--for updating visible counters to their actual values
--counter = {actual, shown, posSound, negSound}
function actuationEvent(c, d)
	local e = {
		class = "actuation",
		counter = c,
		delta = d --or c.actual - c.shown --i wish this worked, but it mis-calculates/actuates if the same counter is changed in multiple queued events
	}
	
	print("+"..d)
		
	return e
end

--TODO construct with above, then mutate args? maybe this can even be done generically for all event types in EventSetQueue?? although defaults wouldn't work
function actuationEventGeneric(args)
	local e = {
		class = "actuation",
		
		counter = counters[args[1]],
		delta = tonumber(args[2])
	}

	return e
end

------------------------------------------------------------------------------------------------------

function actuationEventProcessing(e)
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