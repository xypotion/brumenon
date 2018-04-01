function cellOpEvent(y, x, payload, layer)
	if layer == nil then layer = "sprite" end
	
	local e = {
		class = "cellOp",
		y = y,
		x = x,
		payload = payload,
		layer = layer
	}
	
	-- print("cellop", y, x, layer, payload)
	
	return e
end

------------------------------------------------------------------------------------------------------

function cellOpEventProcessing(e)
	field[e.layer][e.y][e.x] = e.payload
	
	e.finished = true
end