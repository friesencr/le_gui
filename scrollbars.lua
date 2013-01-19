local container = Gui.Element({
	name = 'container',
	styles = {
		-- clip = true,
		height = 300,
		width = 300,
		border_width = 1,
		border_color = Vec4(1,1,1,1)
	}
})

local contents = Gui.Element({
	name = 'contents',
	styles = {
		height = 400,
		width = 200,
		background_color = Vec4(.2,0,0,1)
	}
})

container:add_child(contents)
demo_region:add_child(container)
