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

local function apply_mouse_states(self)

	local hit = Gui.hit_test(
		MouseX(),
		MouseY(),
		self.absolute_coords.top_left.x,
		self.absolute_coords.top_left.y,
		self.absolute_coords.bottom_right.x,
		self.absolute_coords.bottom_right.y
	)

	if hit then
		local clipping_parent = self:get_clip_parent()
		if clipping_parent then
			local parent_hit = Gui.hit_test(
				MouseX(),
				MouseY(),
				clipping_parent.absolute_coords.top_left.x,
				clipping_parent.absolute_coords.top_left.y,
				clipping_parent.absolute_coords.bottom_right.x,
				clipping_parent.absolute_coords.bottom_right.y
			)
			hit = parent_hit
		end
	end

	if hit then
		self:add_state('hover', 3)
	else
		self:remove_state('hover')
	end

	local active = hit and MouseDown(MOUSE_LEFT) == 1
	if active then
		self:add_state('active', 2)
	else
		self:remove_state('active')
	end

end

function Container:add_state(state, priority)
	priority = priority or 1
	if not self.current_state[state] then
		table.insert(self.apply_states, state)
		self.current_state[state] = priority
	end
end

function Container:remove_state(state)
	if self.current_state[state] then
		table.insert(self.remove_states, state)
		self.current_state[state] = nil
	end
end

function Container:set_states()

	apply_mouse_states(self)

	if # self.remove_states > 0 or # self.apply_states > 0 then
		self:apply_styles_and_classes()

		local states = _.keys(self.current_state)
		local _self = self
		states = _.sort(states, function(a,b) return _self.current_state[a] > _self.current_state[b] end)

		for i,v in ipairs(states) do
			self:apply_state(v)
		end
	end

	if self.styles._changed then
		rawset(self.styles,'_changed', false)
		self:apply_styles_and_classes()
	end
end

function Container:capture_events(hit)
	if self.mouse_in then
		if hit == false and Gui.last_mouse_element == self then
			self.mouse_in = false
			self:trigger('mouseout')
			Gui.last_mouse_element = nil
		end
	elseif hit then
		self.mouse_in = true
		self:trigger('mousein')
		Gui.last_mouse_element = self
	end

	if hit then
		local clipping_parent = self:get_clip_parent()
		if clipping_parent then
			local parent_hit = Gui.hit_test(
				MouseX(),
				MouseY(),
				clipping_parent.absolute_coords.top_left.x,
				clipping_parent.absolute_coords.top_left.y,
				clipping_parent.absolute_coords.bottom_right.x,
				clipping_parent.absolute_coords.bottom_right.y
			)
			hit = parent_hit
		end
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
	assert(child)
	child.parent = self
	table.insert(self.children, child)
end

function Container:add_children(children)
	_.each(children, function(x) self:add_child(x) end, self)
end

function Container:init(layout_manager)
	self.apply_states = {}
	self.remove_states = {}
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	layout_manager:layout(self)
	self:set_states()
	layout_manager:layout(self)
	_.each(self.children, function(x) x:init(layout_manager) end)
end

function Container:pre_render(layout_manager)
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	self:set_states()
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
		obj.adjusted_height,
		obj.adjusted_width,
		obj.background_color,
		obj.background_image,
		obj.border_color,
		obj.border_width,
	}
end

local function get_text_cache(obj)
	return {
		obj.adjusted_height,
		obj.adjusted_width,
		obj.text,
		obj.font,
		obj.color
	}
end

function Container:render(border_renderer, background_render, text_renderer)
	if self.clip then
		local clip_buffer_cache = { self.adjusted_width, self.adjusted_height }
		if not Gui.util.compare_tables(self.clip_buffer_cache, clip_buffer_cache) then
			self.clip_buffer = CreateBuffer(math.max(2, self.adjusted_width), math.max(2, self.adjusted_height), BUFFER_COLOR)
			self.clip_buffer_cache = clip_buffer_cache
		end

		if self.clip_buffer then
			SetBuffer(self.clip_buffer)
			SetColor(Vec4(0,0,0,0))
			self.clip_buffer:Clear(BUFFER_COLOR)
		end
	end

	local buffer_cache = { self.width, self.height }
	if not Gui.util.compare_tables(self.buffer_cache, buffer_cache) then
		self.buffer = CreateBuffer(math.max(2,self.width), math.max(2,self.height), BUFFER_COLOR)
		self.buffer_cache = buffer_cache
	end

	local render_cache = get_render_cache(self)
	if not Gui.util.compare_tables(self.render_cache, render_cache) then
		SetBuffer(self.buffer)
		SetColor(Vec4(0,0,0,0))
		self.buffer:Clear(BUFFER_COLOR)
		background_render:draw_background_color(self)
		background_render:draw_background_image(self)
		border_renderer:draw_border(self)
		self.color_render = GetColorBuffer(self.buffer)
		self.render_cache = render_cache
	end

	local text_buffer_cache = { self.adjusted_width, self.adjusted_height }
	if not Gui.util.compare_tables( self.text_buffer_cache, text_buffer_cache ) then
		self.text_buffer = CreateBuffer(math.max(2, self.adjusted_width), math.max(2,self.adjusted_height), BUFFER_COLOR)
		self.text_buffer_cache = text_buffer_cache
	end

	local text_cache = get_text_cache(self)
	if not Gui.util.compare_tables(self.text_cache, text_cache) then
		SetBuffer(self.text_buffer)
		SetColor(Vec4(0,0,0,0))
		ClearBuffer(self.text_buffer)
		self.text_buffer:Clear(BUFFER_COLOR)
		text_renderer:draw_text(self)
		self.text_render = GetColorBuffer(self.text_buffer)
		self.text_cache = text_cache
	end
end

local function _search_parents(obj, result, predicate)
	if obj then
		if predicate(obj) then
			result.value = obj
			return
		else
			_search_parents(obj.parent, result, predicate)
		end
	end
end

local function _search_children(obj, result, predicate)
	if obj and obj.children and # obj.children > 0 then
		local matches = _.select(obj.children, predicate)
		table.concat(result, matches)
		_.each(obj.children, function(x)
				_search_children(x, predicate, ret)
			end)
	end
end

function Container:get_clip_parent()
	return self:find_parent(function(x) return x.clip end)
end

function Container:get_clip_buffer()
	local parent = self:get_clip_parent()
	if parent then
		return parent.clip_buffer
	else
		return BackBuffer()
	end
end

function Container:find_self_or_child(predicate)
	local result = { values = {}}
	_search_parents(self, result, predicate)
	return result.values
end

function Container:find_self_or_parent(predicate)
	local result = {}
	_search_parents(self, result, predicate)
	return result.value
end

function Container:find_parent(predicate)
	local result = {}
	_search_parents(self.parent, result, predicate)
	return result.value
end

function Container:find_child(predicate)
	local result = { values = {} }
	_search_children(self.parent, result, predicate)
	return result.value
end

Gui.Container = Container
