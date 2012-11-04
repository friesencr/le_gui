require "scripts/constants/keycodes"
require "scripts/constants/engine_const"
require "lib/lua_emitter/src/emitter"
require "lib/underscore"

local _ = Underscore:new()

local Container = { }
Container.__index = Container

function print_table(obj) AppLog(table.ToString(obj, 'table', true)) end
function print_args(...)
	local arg = {...}
	_.each(arg, function(x) AppLog(x) end)
	return unpack(arg)
end

local function table_merge(dest, source)
	for k,v in pairs(source) do
		dest[k] = v
	end
end

local function compare_tables(a, b)
	local same = true
	if a == b then same = true
	elseif (a and not b) or (not a and b) then same = false 
	elseif (#a ~= #b) then same = false
	else
		for i,v in ipairs(b) do
			same = a[i] ~= v
			if not same then break end
		end
	end
	return same
end

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
		text = nil,
		class = {},
		state = {},
		styles = {},
	}

	-- obj.apply_styles_and_classes = Container.apply_styles_and_classes
	-- obj.apply_state = Container.apply_state
	-- obj.calculate_bounds = Container.calculate_bounds
	-- obj.draw_border = Container.draw_border
	-- obj.draw_text = Container.draw_text
	-- obj.draw_background = Container.draw_background
	-- obj.set_states = Container.set_states
	-- obj.capture_events = Container.capture_events
	-- obj.add_child = Container.add_child
	-- obj.add_children = Container.add_children
	-- obj.pre_init = Container.pre_init
	-- obj.init = Container.init
	-- obj.pre_render = Container.pre_render
	-- obj.render = Container.render
	-- obj.find_parent = Container.find_parent
	-- obj.find_child = Container.find_child
	--
	setmetatable(obj, Container)

	table_merge(obj, Gui.default_styles)
	table_merge(obj, values)
	Emitter:new(obj)
	obj._identity = Gui.id
	Gui.id = Gui.id + 1
	local _styles = obj.styles
	obj.styles = { _values = {} }
	setmetatable(obj.styles, styles_mt)
	table_merge(obj.styles, _styles)
	obj:apply_styles_and_classes()
	table.insert(Gui.elements, obj)
	return obj
end

function Container:apply_styles_and_classes()
	table_merge(self, Gui.default_styles)
	for i,class in ipairs(self.class) do
		table_merge(self, class)
	end
	table_merge(self, rawget(self.styles, '_values'))
end

function Container:apply_state(state)
	if self.state[state] then
		table_merge(self, self.state[state])
	end
	table_merge(self, rawget(self.styles, '_values'))
end

local function str_split(str, sSeparator, nMax, bRegexp)
	assert(str)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if str:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField=1 nStart=1
		local nFirst,nLast = str:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = str:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = str:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = str:sub(nStart)
	end

	return aRecord
end

function Container:set_child_position(child)
	assert(child)
	if child.display == 'block' then

	elseif child.display == 'inline' then

	end
end

function Container:calculate_position()
	self.offset_x = self.border_width + self.padding_left
	self.offset_y = self.border_width + self.padding_top
	self.adjusted_x = self.x + self.offset_x
	self.adjusted_y = self.y + self.offset_y

	local alignment_offset_x = 0
	if self.horizontal_align == 'center' then
		alignment_offset_x = (self.parent_width - self.width) / 2
	elseif self.horizontal_align == 'right' then
		alignment_offset_x = self.parent_width - self.width
	end

	self.alignment_offset_x = alignment_offset_x
	self.aligned_x = self.x + alignment_offset_x

	-- add parent offset
	local absolute_x = self.x + alignment_offset_x
	if self.parent then
		absolute_x = absolute_x + self.parent.absolute_x + self.parent.offset_x
	end
	self.absolute_x = absolute_x

	-- Calculate Y
	local absolute_y = self.y
	if self.parent then
		absolute_y = absolute_y + self.parent.absolute_y + self.parent.offset_y
	end
	self.absolute_y = absolute_y

	-- Set Coordinates
	local top_left = {
		x = self.absolute_x,
		y = self.absolute_y
	}

	local top_right = {
		x = self.absolute_x + self.width - 1,
		y = self.absolute_y
	}

	local bottom_left = {
		x = self.absolute_x,
		y = self.absolute_y + self.height - 1
	}

	local bottom_right = {
		x = self.absolute_x + self.width - 1,
		y = self.absolute_y + self.height - 1
	}

	self.coords = {
		top_left = top_left,
		top_right = top_right,
		bottom_left = bottom_left,
		bottom_right = bottom_right
	}
end

function Container:calculate_bounds()
	local parent_width = self.parent and self.parent.adjusted_width or GraphicsWidth()
	local parent_height = self.parent and self.parent.adjusted_height or GraphicsHeight()

	self.parent_width = parent_width
	self.parent_height = parent_height

	-- Calculate width
	if not self.width then
		self.actual_width = self.parent_width
		if self.dispaly == "inline" and self.text then
			local text_width = TextWidth(self.text) + self.padding_left + 
				self.padding_right + self.border_width * 2

			if text_width < parent_width then
				self.width = text_width
			end
		end
	end

	-- Calculate adjusted width
	self.adjusted_width = self.width -
		self.padding_left -
		self.padding_right -
		self.border_width * 2

	-- Calculate height
	if not self.height then
		self.actual_height = self.parent_height
		self:calculate_text(self.adjusted_width)

		self.height = self.line_height * # self.lines_of_text + self.padding_top
			+ self.padding_bottom + self.border_width * 2

	end

	-- Calculate adjusted height
	self.adjusted_height = self.height -
		self.padding_top -
		self.padding_bottom -
		self.border_width * 2

end

function Container:draw_border()
	-- print_table(self)
	SetColor(self.border_color)
	if self.border_width > 0 then

		local top_left = { x=0, y=0 }
		local top_right = { x=self.width-1, y=0 }
		local bottom_left = { x=0, y=self.height-1 }
		local bottom_right = { x=self.width-1, y=self.height-1 }

		for width = 0, self.border_width - 1 do

			-- top border
			DrawLine(
				top_left.x + width,
				top_left.y + width,
				top_right.x - width,
				top_right.y + width)

			-- right border
			DrawLine(
				top_right.x - width,
				top_right.y + width +1,
				bottom_right.x - width,
				bottom_right.y - width -1)

			-- bottom border
			DrawLine(
				bottom_right.x - width,
				bottom_right.y - width,
				bottom_left.x + width,
				bottom_left.y - width)

			-- left border
			DrawLine(
				bottom_left.x + width,
				bottom_left.y - width -1,
				top_left.x + width,
				top_left.y + width +1)

		end
	end
end

function Container:calculate_text(width)
	if not self.text then do return end end
	if not compare_tables(self.text_cache, { self.text, width }) then
		local words = str_split(self.text, ' ')
		local text_x = 0
		local lines = {
			word_count = 0
		}
		local line = {}
		table.insert(lines, line)

		for i,v in ipairs(words) do
			local text = v
			if # line > 0 then
				-- add space if its not the first word
				text = ' ' .. v
			end

			-- calculate width
			local text_width = TextWidth(text)

			-- if it doesnt fit on the line create a new line
			if text_x + text_width > width then
				text_x = 0
				text = v
				text_width = TextWidth(text)
				line = {}
				table.insert(lines, line)
			end

			-- insert calculated word in line
			table.insert(line, {
				text = text,
				x = text_x,
				text_width = text_width,
			})

			line.width = (line.width or 0) + text_width

			-- set the x position for the next word
			text_x = text_x + text_width
			self.lines_of_text = lines
			self.text_cache = {
				self.text,
				width
			}
		end
	end
end

function Container:draw_text()
	if self.font then
		SetFont(self.font)
	end
	if self.text then
		SetColor(self.color)
		-- only calculate if needed
		-- render text
		for y,line in ipairs(self.lines_of_text) do
			local x_offset = 0
			-- adjust for center align
			if self.text_align == 'center' then
				x_offset = (self.adjusted_width - line.width) / 2
			-- adjust for right align
			elseif self.text_align == 'right' then
				x_offset = (self.adjusted_width - line.width)
			end
			-- render every word on line
			for i, word in ipairs(line) do
				DrawText(word.text,
					word.x + self.offset_x + x_offset + self.text_offset_x,
					((y - 1) * self.line_height) + self.offset_y + self.text_offset_y
				)
			end
		end
	end
end

function Container:draw_background()
	if self.background_image then
		DrawImage(self.background_image,
			0,
			0,
			self.width,
			self.height
		)
	end
	if self.background_color then
		SetColor(self.background_color)
		DrawRect(
			0 + self.border_width,
			0 + self.border_width,
			self.width - self.border_width * 2,
			self.height - self.border_width * 2
		)
	end
end

function Container:set_states()
	local hit = Gui.hit_test(
		MouseX(),
		MouseY(),
		self.coords.top_left.x,
		self.coords.top_left.y,
		self.coords.bottom_right.x,
		self.coords.bottom_right.y
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

function Container:pre_init()
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	self:calculate_bounds()
	self:calculate_text(self.adjusted_width)
	self:calculate_position()
	_.each(self.children, function(x) x:pre_init() end)
end

function Container:init()
	self:set_states()
	self:calculate_bounds()
	self:calculate_position()
	_.each(self.children, function(x) x:init() end)
end

function Container:pre_render()
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	self:calculate_bounds()
	self:calculate_text(self.adjusted_width)
	self:calculate_position()
	_.each(self.children, function(x) x:pre_render() end)
end

local counter = 0
function Container:render()
	if not self.buffer then
		self.buffer = CreateBuffer(self.width, self.height, BUFFER_COLOR)
		self.render_buffer = CreateBuffer(self.width, self.height, BUFFER_COLOR)
	end
	SetBuffer(self.buffer)
	self:draw_background()
	self:draw_border()
	self:draw_text()
	self.color_buffer = GetColorBuffer(self.buffer)
end

-- function Container:cache_key()
--	return {
--		self.width,
--		self.height,
--		self.border_width,
--		self.border_color,
--		self.background_image,
--		self.background_color,
--		self.text,
--		self.text_offset_y,
--		self.font,
--		self.color
--	}
-- end

-- function Container:parent_cache_key()
--	return {
--		self.x,
--		self.y
--	}
-- end

-- function Container:expire_parent()
--	local key = self:parent_cache_key()
--	local expired = false
--	if self.last_parent_cache and # self.parent_last_cache == # key then
--		for i,v in ipairs(key) do
--			expired = self.parent_last_cache[i] ~= key[i]
--			if expired then break end
--		end
--	else
--		expired = true
--	end
--	self.parent_last_cache = key
--	return expired
-- end

-- function Container:expire_cache()
--	local key = self:cache_key()
--	local expired = false
--	if self.last_cache and # self.last_cache == # key then
--		for i,v in ipairs(key) do
--			expired = self.last_cache[i] ~= key[i]
--			if expired then break end
--		end
--	else
--		expired = true
--	end
--	self.last_cache = key
--	AppLog('expired ' .. tostring(expired))
--	return expired
-- end

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
