require "scripts/table"
require "scripts/constants/keycodes"
require "underscore"

local _ = Underscore:new()

Emitter = {}

function Emitter:create()
	local obj = {}
	obj.callbacks = {}
	obj.on = Emitter.on
	obj.off = Emitter.off
	obj.trigger = Emitter.trigger
	return obj
end

function Emitter:on(event, callback)
	local event_callbacks = self.callbacks[event]
	if not event_callbacks then
		event_callbacks = {}
		self.callbacks[event] = event_callbacks
	end
	table.insert(event_callbacks, callback)
end

function Emitter:off(event, callback)
	if not callback then
		self.callbacks[event] = {}
	else
		local event_callbacks = self.callbacks[event]
		local do_continue = event_callbacks
		for i,v in ipairs(event_callbacks) do
			if v == callback then
				table.remove(event_callbacks, i)
				break
			end
		end
	end
end

local function fire_callbacks(ele, event, e, arg)
	local event_callbacks = ele.callbacks[event]
	if event_callbacks then
		local i = 1
		while not e.stop_propagation and i <= # event_callbacks do
			local callback = event_callbacks[i]
			callback(e, arg)
			i = i+1
		end
	end
	if ele.parent then fire_callbacks(ele.parent, event, e, arg) end
end

function Emitter:trigger(event, arg)
	local e = {
		name = event,
		target = self,
		stop_propagation = false
	}
	fire_callbacks(self, event, e, arg)
end

local Container = { }

Container.__index = Container

function Container:create(attributes)
	local obj = {
		parent = nil,
		children = {},
		text = nil,
		state = {},
		current_state = {},
		callbacks = {},
	}
	obj.attributes = attributes or {}
	table.Merge(self, Gui.default_attributes)
	table.Merge(obj, Emitter:create())
	setmetatable(obj, Container)
	obj._identity = Gui.id
	Gui.id = Gui.id + 1
	table.insert(Gui.elements, obj)
	return obj
end

function Container:apply_attributes_and_classes(source)
	for i,class in ipairs(source.class or {}) do
		table.Merge(self, class)
	end
	table.Merge(self, source.attributes or {})
end

function Container:apply_states()
	for k,v in pairs(self.state) do
		if self.current_state[k] then
			local x = {
				attributes = v,
				class = v.class
			}
			self:apply_attributes_and_classes(x)
		end
	end
end

function Container:calculate_bounds()
	local parent_width = self.parent and self.parent.adjusted_width or GraphicsWidth()
	local parent_height = self.parent and self.parent.adjusted_height or GraphicsHeight()

	self.width = self.width or parent_width
	self.width = self.width or parent_height

	self.offset_x = self.border_width + self.padding_left
	self.offset_y = self.border_width + self.padding_top
	self.adjusted_x = self.x + self.offset_x
	self.adjusted_y = self.y + self.offset_y

	-- Calculate adjusted width
	self.adjusted_width = self.width -
		self.padding_left -
		self.padding_right -
		self.border_width * 2

	-- Calculate adjusted height
	self.adjusted_height = self.height -
		self.padding_top -
		self.padding_bottom -
		self.border_width * 2

	-- Calculate X
	-- figure aligment
	local alignment_offset_x = 0
	if self.horizontal_align == 'center' then
		alignment_offset_x = (parent_width - self.width) / 2
	elseif self.horizontal_align == 'right' then
		alignment_offset_x = parent_width - self.width
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

function alert(val, message)
	Notify(tostring(val)..(message or ''))
	return val
end

function Container:draw_border()
	if self.border_width > 0 then
		SetBlend(1)
		SetColor(self.border_color)

		local top_left = self.coords.top_left
		local top_right = self.coords.top_right
		local bottom_left = self.coords.bottom_left
		local bottom_right = self.coords.bottom_right

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

		SetBlend(0)
	end
end

function Container:draw_text()
	if self.font then
		SetFont(self.font)
	end
	if self.text then
		SetBlend(1)
		SetColor(self.color)

		-- only calculate if needed
		if self.last_text ~= self.text then

			local words = string.split(self.text, ' ')
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
				if text_x + text_width > self.adjusted_width then
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
			end
		end

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
					word.x + self.absolute_x + self.offset_x + x_offset,
					((y - 1) * self.line_height) + self.absolute_y + self.offset_y
				)
			end
		end

		self.last_text = self.text

		SetBlend(0)
	end
end

function Container:draw_background()
	SetBlend(1)
	if self.background_color then
		SetColor(self.background_color)
		DrawRect(
			self.absolute_x + self.border_width,
			self.absolute_y + self.border_width,
			self.width - self.border_width * 2,
			self.height - self.border_width * 2
		)
	end
	SetBlend(0)
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
	self.current_state.hover = hit
	self.current_state.active = hit and MouseDown(MOUSE_LEFT) == 1
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
	self:apply_attributes_and_classes(self)
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	self:calculate_bounds()
	_.each(self.children, function(x) x:pre_init() end)
end

function Container:init()
	self:set_states()
	self:apply_states()
	self:calculate_bounds()
	_.each(self.children, function(x) x:init() end)
end

function Container:pre_render()
	self.zindex = self.parent and self.parent.zindex + 1 or 1
	self:calculate_bounds()
	_.each(self.children, function(x) x:pre_render() end)
end

function Container:render()
	self:draw_border()
	self:draw_background()
	self:draw_text()
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

function string.split(str, sSeparator, nMax, bRegexp)
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

Gui.Container = Container
