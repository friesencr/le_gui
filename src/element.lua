AppLog('gui - initializing element')

local _ = Underscore:new()
local c = Gui.util.get_value

local function get_all_parents(element, names)
	table.insert(names, element)
	if element.parent then
		get_all_parents(element.parent, names)
	end
end

local styles_mt = {
	__index = function(table, key)
		return rawget(table._values, key)
	end,
	__newindex = function(table, key, value)
		rawset(table._values, key, value)
		rawset(table,'_changed',true)
		rawset(table.element, key, value)
	end
}

local Element = {

	merge = function(self, ...)
		Gui.util.table_merge(self, ...)
	end

	, initialize = function(self)
		self:merge(Gui.get_styles_from_stylesheet(self) or {})
		local _styles = self.styles
		self.styles = { _values = {}, element = self }
		setmetatable(self.styles, styles_mt)
		self.merge(self.styles, _styles)
		self:apply_styles_and_classes()
	end

	, apply_styles_and_classes = function(self)
		self:merge(Gui.default_styles)
		self:merge(unpack(self.class or {}))
		self:merge(rawget(self.styles, '_values'))
	end

	, apply_state = function(self, state)
		if self.state[state] then
			self:merge(self.state[state])
		end
		self:merge(rawget(self.styles, '_values'))
	end

	, apply_mouse_states = function(self)

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

	, hide = function(self)
		self._show = false
		return self
	end

	, show = function(self)
		self._show = true
		return self
	end

	, is_hidden = function(self)
		return self:find_self_or_parent(function(x) return x._show ~= true end) ~= nil
	end

	, add_state = function(self, state, priority)

		priority = priority or 1
		if not self.current_state[state] then
			table.insert(self.apply_states, state)
			self.current_state[state] = priority
		end
		return self
	end

	, remove_state = function(self, state)
		if self.current_state[state] then
			table.insert(self.remove_states, state)
			self.current_state[state] = nil
		end
		return self
	end

	, set_states = function(self)
		if self.initialized then
			self:apply_mouse_states()

			if # self.remove_states > 0 or # self.apply_states > 0 then
				self:apply_styles_and_classes()

				local states = _.keys(self.current_state) or {}
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
	end

	, init = function(self, layout_manager)
		if not self.initialized then
			self.initialized = true
			AppLog(self:full_name() .. ' initialized')
		end
		self.apply_states = {}
		self.remove_states = {}
		self.zindex = self.parent and self.parent.zindex + 1 or 1
		self:trigger('pre_init', nil, { no_bubble = true })
		layout_manager:layout(self)
		self:set_states()
		layout_manager:layout(self)
		_.each(self.children, function(x) x:init(layout_manager) end)
		if self.scrolling_x then
			self.scrollbar_x:init(layout_manager)
		end
		if self.scrolling_y then
			self.scrollbar_y:init(layout_manager)
		end
		layout_manager:inner_sizes(self)
		self:trigger('init', nil, { no_bubble = true })
	end

	, pre_render = function(self, layout_manager)
		if self.initialized then
			self:trigger('pre_render', nil, { no_bubble = true })
			self.zindex = self.parent and self.parent.zindex + 1 or 1
			self:set_states()
			layout_manager:inner_sizes(self)
			self:calculate_scrollbars()
			layout_manager:layout(self)
			_.each(self.children, function(x) x:pre_render(layout_manager) end)
			if self.scrolling_x then
				self.scrollbar_x:pre_render(layout_manager)
			end
			if self.scrolling_y then
				self.scrollbar_y:pre_render(layout_manager)
			end
		end
	end

	, get_render_cache = function(self)
		return {
			c(self.height, self),
			c(self.width, self),
			c(self.padding_right, self),
			c(self.padding_left, self),
			c(self.padding_top, self),
			c(self.padding_bottom, self),
			c(self.background_color, self),
			c(self.background_image, self),
			c(self.border_color, self),
			c(self.border_width, self),
		}
	end

	, get_text_cache = function(self)
		return {
			self.adjusted_height,
			self.adjusted_width,
			c(self.text, self),
			self.font,
			c(self.color, self),
		}
	end

	, render = function(self, border_renderer, background_render, text_renderer)
		if self.initialized then
			self:trigger('render', nil, { no_bubble = true })
			if self.clip then
				local clip_buffer_cache = { self.adjusted_width, self.adjusted_height }
				if not Gui.util.compare_tables(self.clip_buffer_cache, clip_buffer_cache) then
					self.clip_buffer = Gui.util.get_buffer(math.max(2, self.adjusted_width), math.max(2, self.adjusted_height), BUFFER_COLOR)
					self.clip_buffer_cache = clip_buffer_cache
				end

				if self.clip_buffer then
					SetBuffer(self.clip_buffer)
					SetColor(Vec4(0,0,0,0))
					ClearBuffer(BUFFER_COLOR)
				end
			end

			local buffer_cache = { self.width, self.height }
			if not Gui.util.compare_tables(self.buffer_cache, buffer_cache) then
				self.buffer = Gui.util.get_buffer(math.max(2,self.width), math.max(2,self.height), BUFFER_COLOR)
				self.buffer_cache = buffer_cache
			end

			local render_cache = self:get_render_cache()
			if not Gui.util.compare_tables(self.render_cache, render_cache) then
				SetBuffer(self.buffer)
				SetColor(Vec4(0,0,0,0))
				ClearBuffer(BUFFER_COLOR)
				background_render:draw_background_color(self)
				background_render:draw_background_image(self)
				border_renderer:draw_border(self)
				self.color_render = GetColorBuffer(self.buffer)
				self.render_cache = render_cache
			end

			local text_buffer_cache = { self.adjusted_width, self.adjusted_height }
			if not Gui.util.compare_tables( self.text_buffer_cache, text_buffer_cache ) then
				self.text_buffer = Gui.util.get_buffer(math.max(2, self.adjusted_width), math.max(2,self.adjusted_height), BUFFER_COLOR)
				self.text_buffer_cache = text_buffer_cache
			end

			local text_cache = self:get_text_cache()
			if not Gui.util.compare_tables(self.text_cache, text_cache) then
				SetBuffer(self.text_buffer)
				SetColor(Vec4(0,0,0,0))
				ClearBuffer(BUFFER_COLOR)
				text_renderer:draw_text(self)
				self.text_render = GetColorBuffer(self.text_buffer)
				self.text_cache = text_cache
			end

			if self.scrolling_x then
				self.scrollbar_x:render(border_renderer, background_render, text_renderer)
			end
			if self.scrolling_y then
				self.scrollbar_y:render(border_renderer, background_render, text_renderer)
			end
		end
	end

	, get_clip_parent = function(self)
		return self:find_parent(function(x) return x.clip end)
	end

	, get_clip_buffer = function(self)
		local parent = self:get_clip_parent()
		return parent and parent.clip_buffer or BackBuffer()
	end

	, destroy = function(self)
		AppLog('destroying ' .. self:full_name())
		if self.clip_buffer then self.clip_buffer:Free() end
		if self.buffer then self.buffer:Free() end
		if self.text_buffer then self.text_buffer:Free() end
		if self.scrollbar_x then
			self.scrollbar_x:destroy()
			self.scrollbar_x = nil
		end
		if self.scrollbar_y then
			self.scrollbar_y:destroy()
			self.scrollbar_y = nil
		end
		if self.children then
			for i,v in ipairs(self.children) do
				v:destroy()
			end
			self.children = {}
		end
		Gui.destroy_element(self)
		return self
	end

	, clear = function(self)
		if self.children then
			for i,v in ipairs(self.children) do
				v:destroy()
			end
			self.children = {}
		end
		return self
	end

	, detach = function(self)
		return self
	end

	, attach = function(self)
		return self
	end

	, full_name = function(self)
		local parents = _.reverse(self:get_parents())
		local name = ''
		for i,v in ipairs(parents) do
			if i ~= 1 then name = name .. '.' end
			name = name .. v.name .. '[' .. v._identity .. ']'
		end
		return name
	end

	, get_parents = function(self)
		local parents = {}
		get_all_parents(self, parents)
		return parents
	end

	, set_parent = function(self, parent)
		self.parent = parent
		self:initialize()
		if self.children then
			_.each(self:find_children(), function(x) x:initialize() end)
		end
	end
}

function Element:new(values)
	if not values and name and type(name) == 'table' then
		values = name
	end
	local obj = {
		renderable = true,
		parent = nil,
		text = nil,
		state = {},
		current_state = {},
		class = {},
		state = {},
		styles = {},
		_show = true,
		initialized = false,
	}
	Emitter:new(obj)
	Element.merge(obj, Element)
	obj:merge(Gui.ElementList())
	obj:merge(Gui.Animatable)
	obj:merge(Gui.Scrollable)
	if values then obj:merge(values) end
	Gui.init_element(obj)
	if not obj.name then
		obj.name = obj._identity
	end
	obj.new = nil
	obj:initialize()
	return obj
end

setmetatable(Element, { __call = function(x, ...) return Element:new(...) end })

Gui.Element = Element
