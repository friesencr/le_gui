require "scripts/constants/keycodes"
require "scripts/constants/engine_const"
require "lib/lua_emitter/src/emitter"
require "lib/underscore"

local _ = Underscore:new()

local Container = { }
Container.__index = Container

local styles_mt = {
	__index = function(table, key)
		return rawget(table._values, key)
	end,
	__newindex = function(table, key, value)
		rawset(table._values, key, value)
		rawset(table,'_changed',true)
	end
}

function Container:new(values)
	local obj = {
		parent = nil,
		children = {},
		text = nil,
		state = {},
		current_state = {},
		callbacks = {},
		class = {},
		state = {},
		styles = {},
		render_rows = {}
	}
	setmetatable(obj, Container)

	Gui.util.table_merge(obj, Gui.default_styles)
	Gui.util.table_merge(obj, values)
	Emitter:new(obj)
	obj._identity = Gui.id
	Gui.id = Gui.id + 1
	local _styles = obj.styles
	obj.styles = { _values = {} }
	setmetatable(obj.styles, styles_mt)
	Gui.util.table_merge(obj.styles, _styles)
	obj:apply_styles_and_classes()
	table.insert(Gui.elements, obj)
	return obj
end

function Container:apply_styles_and_classes()
	Gui.util.table_merge(self, Gui.default_styles)
	for i,class in ipairs(self.class) do
		Gui.util.table_merge(self, class)
	end
	Gui.util.table_merge(self, rawget(self.styles, '_values'))
end

function Container:apply_state(state)
	if self.state[state] then
		Gui.util.table_merge(self, self.state[state])
	end
	Gui.util.table_merge(self, rawget(self.styles, '_values'))
end

function Container:set_states()
	local hit = Gui.hit_test(
		MouseX(),
		MouseY(),
		self.absolute_coords.top_left.x,
		self.absolute_coords.top_left.y,
		self.absolute_coords.bottom_right.x,
		self.absolute_coords.bottom_right.y
	)

	local state_changes = 0
	if self.current_state.hover ~= hit then
		state_changes = state_changes + 1
		self.current_state.hover = hit
		if hit then
			self:apply_state('hover')
		else
			self.current_state.hover = false
		end
	end

	local active = hit and MouseDown(MOUSE_LEFT) == 1
	if self.current_state.active ~= active then
		state_changes = state_changes + 1
		self.current_state.active = active
		if active then
			self:apply_state('active')
		else
			self.current_state.active = false
			if hit then
				self:apply_styles_and_classes()
				self:apply_state('hover')
			end
		end
	end

	if self.styles._changed or not self.current_state.hover and state_changes > 0 then
		rawset(self.styles,'_changed', false)
		self:apply_styles_and_classes()
	end
end

function Container:capture_events(hit)
	if self.mouse_in then
		if hit == false and Gui.last_mouse_element == self then
			self.mouse_in = false
			self.current_state['hover'] = false
			self:trigger('mouseout')
			Gui.last_mouse_element = nil
		end
	elseif hit then
		self.mouse_in = true
		self.current_state['hover'] = true
		self:trigger('mousein')
		Gui.last_mouse_element = self
	end

	if hit then
		if Gui.events.mouse_down[MOUSE_LEFT] then
			Gui.last_mouse_down = self
		elseif Gui.events.mouse_down[MOUSE_RIGHT] then
			Gui.last_mouse_down = self
		elseif Gui.events.mouse_down[MOUSE_MIDDLE] then
			Gui.last_mouse_down = self
		end
	end

	if hit and Gui.last_mouse_down == self then
		if Gui.events.mouse_up[MOUSE_LEFT] then
			self:trigger('click', { button = MOUSE_LEFT } )
		elseif Gui.events.mouse_up[MOUSE_RIGHT] then
			self:trigger('click', { button = MOUSE_RIGHT } )
		elseif Gui.events.mouse_up[MOUSE_MIDDLE] then
			self:trigger('click', { button = MOUSE_MIDDLE } )
		end
	end
end

function Container:add_child(child)
	child.parent = self
	table.insert(self.children, child)
end

function Container:add_children(children)
	_.each(children, function(x) self:add_child(x) end, self)
end

function Container:pre_init(layout_manager)
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	layout_manager:layout(self)
	_.each(self.children, function(x) x:pre_init(layout_manager) end)
end

function Container:init(layout_manager)
	self:set_states()
	layout_manager:layout(self)
	_.each(self.children, function(x) x:init(layout_manager) end)
end

function Container:pre_render(layout_manager)
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	layout_manager:layout(self)
	_.each(self.children, function(x) x:pre_render(layout_manager) end)
end

local function get_render_cache(obj)
	return {
		obj.height,
		obj.width,
		obj.padding_right,
		obj.padding_left,
		obj.padding_top,
		obj.padding_bottom,
		obj.background_color,
		obj.background_image,
		obj.border_color,
		obj.border_width,
		obj.text,
		obj.font,
		obj.color
	}
end

function Container:render(border_renderer, background_render, text_renderer)
	local render_cache = get_render_cache(self)
	if not Gui.util.compare_tables(self.render_cache, render_cache) then
		self.buffer = CreateBuffer(self.width, self.height, BUFFER_COLOR)
		self.render_buffer = CreateBuffer(self.width, self.height, BUFFER_COLOR)
		SetBuffer(self.buffer)
		background_render:draw_background_color(self)
		border_renderer:draw_border(self)
		text_renderer:draw_text(self)
		self.color_buffer = GetColorBuffer(self.buffer)
		self.render_cache = render_cache
	end
end

local function _search_parents(obj, predicate)
	if obj then
		if predicate(obj) then
			return obj
		else
			_search_parents(obj.parent, predicate)
		end
	end
end

local function _search_children(obj, predicate, ret)
	if obj and obj.children and # obj.children > 0 then
		local matches = _.select(obj.children, predicate)
		table.concat(ret, matches)
		_.each(obj.children, function(x)
				_search_children(x, predicate, ret)
			end)
	end
end

function Container:find_parent(predicate)
	return _search_parents(self, predicate)
end

function Container:find_child(predicate)
	return _search_children(self, predicate, {})
end

Gui.Container = Container
