Mouse = {}
Mouse.__index = Mouse

function Mouse:new()
	local obj = {}
	obj.enabled = true
	obj.states = {
		normal = LoadTexture("abstract::mouse_normal.dds"),
		hover = LoadTexture("abstract::mouse_hover.dds"),
	}
	obj.state = 'normal'
	setmetatable(obj, Mouse)
	return obj
end

function Mouse:set_cursor()

end

function Mouse:draw()
	if self.enabled then
		DrawImage(self.states[self.state], MouseX(), MouseY(), 32, 32)
	end
end

function Mouse:enable()
	self.enabled = true
end

function Mouse:disable()
	self.enabled = false
end
