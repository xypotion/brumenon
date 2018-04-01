function screenSlideEvent(dir)
	local e = {class = "screenSlide"}
	
	if dir == "north" then
		--
	end
	
	print("hello")
	
	return e
end

function screenSlideEventProcessing(e)
	e.finished = true
end

--freeze current field into a graphic? then draw next, without sprites, as it moves in

--OR load & draw just one extra row/column of the field at a time? that doesn't seem easier/better, though...