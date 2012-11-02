assert(require("scripts/table"))
assert(require("scripts/hooks"))
assert(require("lib/underscore"))
assert(require("lib/lua_promise/src/promise"))
assert(require("lib/tween/tween"))

local _ = Underscore:new()

Gui = {
	id = 1,
	elements = {}
}

function Gui.hit_test(x, y, x1, y1, x2, y2)
	local hit = x >= x1 and x <= x2 and y >= y1 and y <= y2
	return hit
end

Gui.default_styles = {
	x = 0,
	y = 0,
	height = nil,
	width = nil,
	padding_top = 0,
	padding_left = 0,
	padding_bottom = 0,
	padding_right = 0,
	border_width = 0,
	border_color = Vec4(0,0,0,1),
	background_color = nil,
	background_image = nil, --texture
	color = nil,
	line_height = 14,
	font = nil,
	horizontal_align = 'left',
	text_align = 'left',
	text_offset_x = 0,
	text_offset_y = 0,
}

Gui.events = {
	_last_time = nil,
	_current_time = nil,
	last_mouse_x = nil,
	last_mouse_y = nil,
	mouse_x = nil,
	mouse_y = nil,
	mem = {},
	is_key_down = {},
	is_mouse_down = {},
}

local function set_mouse_state(context, button, mouse_down)
	if not context.is_mouse_down[button] and mouse_down == 1 then
		context.is_mouse_down[button] = true
		context.mouse_down[button] = true
	elseif context.is_mouse_down[button] and mouse_down == 0 then
		context.is_mouse_down[button] = false
		context.mouse_up[button] = true
	end
end

function Gui:capture_events()
	local test = function(x) 
		return Gui.hit_test(
			MouseX(),
			MouseY(),
			x.coords.top_left.x,
			x.coords.top_left.y,
			x.coords.bottom_right.x,
			x.coords.bottom_right.y
		)
	end

	-- detect mouse click
	local hit_element = _(self.elements):chain()
		:sort(function(x, y) return x.zindex > y.zindex end)
		:detect(test)
		:value()

	_.each(self.elements, function(x) x:capture_events(x == hit_element) end)
end

function Gui.events:refresh()
	self.last_time = self.current_time
	self.current_time = time
	self.mouse_down = {}
	self.mouse_up = {}
	self.key_down = {}
	self.key_up = {}
	set_mouse_state(self, 1, MouseDown(1))
	set_mouse_state(self, 2, MouseDown(2))
	set_mouse_state(self, 3, MouseDown(3))
end

function Gui:init()
	Gui.events:refresh()
	local roots = _.select(self.elements, function(x) return not x.parent end)
	_.each(roots, function(x) x:init() end)
end

function Gui:pre_init()
	local roots = _.select(self.elements, function(x) return x.parent == nil end)
	_.each(roots, function(x)
		x:pre_init()
	end)
end

function Gui:pre_render()
	_.each(self.elements, function(x) x:pre_render() end)
end

function Gui:render()
	SetBlend(1)
	local sorted = _.sort(self.elements, function(x, y)
		return x.zindex < y.zindex
	end)
	_.each(sorted, function(x) 
		x:render() 
	end)

	SetBuffer(BackBuffer())
	_.each(sorted, function(x)
		SetColor(Vec4(1,1,1,1))
		DrawImage(x.color_buffer,
			x.absolute_x,
			x.height + x.absolute_y,
			x.width,
			-x.height
		)
	end)

	SetBuffer(BackBuffer())
	mouse:draw()
	SetBlend(0)
end

local function on_flip()
	if # Gui.elements > 0 then
		Gui:pre_init()
		Gui:init()
		Gui:capture_events()
		Gui:pre_render()
		Gui:render()
	end
end

function Gui.setup(settings)
	Gui.settings = settings
	HideMouse()
	mouse = mouse or Mouse:new()
	AddHook("Flip", on_flip)
end

function Gui.free()
	Gui.elements = {}
	RemoveHook("Flip", on_flip)
end

require "lib/le_gui/src/container"
