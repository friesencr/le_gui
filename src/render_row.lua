RenderRow = {}
RenderRow.__index = RenderRow

function RenderRow:new(context, parent)
	local obj = {
		context = context,
		parent = parent,
		width = (parent and parent.width) or GraphicsWidth(),
		height = 0,
		horizontal_align = 'left',
		vertical_align = 'top',
		items = {},
	}
	setmetatable(obj, RenderRow)
	return row
end

function RenderRow:used_width()
	local width = 0
	for i,v in pairs(self.items) do
		width = width + v.width
	end
	return width
end

function RenderRow:add_inline_item(element)
	local fits = false
	if not self.mode == 'block' and element.width + self:used_width() < self.width then
		element.x = self:used_width()
		if element.height > self.height then
			self.height = element.height
		end
		self.mode = 'inline'
		table.insert(self.items, element)
		fits = true
	elseif #self.items == 0 then
		self.mode = 'inline'
		table.insert(self.items, element)
		fits = true
	end
	return fits
end

function RenderRow:add_block_item(element)
	self.mode = 'block'
	self.height = element.height
	table.insert(self.items, element)
end

function RenderRow:position_inline(accumulative_height)

	for i,v in ipairs(items) do
		if v.horizontal_align == 'left' then
			left[#left] = v
			left_width = left_width + v.width
		if v.horizontal_align == 'center' then
			center[#center] = v
			center_width = center_width + v.width
		if v.horizontal_align == 'right' then
			table.insert(right, v)
			right_width = right_width + v.width
		end

		if v.vertical_align == 'top' then
			v.y = accumulative_height
		elseif v.vertical_align == 'middle' then
			v.y = v.y + (self.height - v.height) / 2
		elseif v.vertical_align == 'bottom' then
			v.y = v.y + (self.height - v.height)
		end
	end

	local offset, width_counter = 0, 0
	for i,v in ipairs(left) do
		v.x = width_counter
		width_counter = width_counter + v.width
	end

	offset, width_counter = total_width - right_width, 0
	for i,v in ipairs(right) do
		v.x = width_counter
		width_counter = width_counter + v.width
	end

	local space_left = total_width - (left_width + right_width)
	offset, width_counter = left_width + ((space_left - center_width) / 2), 0
	for i,v in ipairs(center) do
		v.x = width_counter
		width_counter = width_counter + v.width
	end
end

function RenderRow:position_block(accumulative_height)
	local total_width = self.context.width
	local e = self.items[1]
	if not e then do return end end

	-- set x
	if e.horizontal_align == 'left' then
		e.x = 0
	elseif e.horizontal_align == 'center' then
		e.x = (total_width - e.width) / 2
	elseif e.horizontal_align == 'right' then
		e.x = (total_width - e.width)
	end

	-- set y
	e.y = accumulatiee_height
end

function RenderRow:set_positions(accumulative_height)
	local width_remaining = self.context.width
	local center = false

	for i,v in items do

		if not v.x then
			if v.display == 'block' then
			elseif v.display == 'inline' then
				if center then

				elseif self.horizontal_align == 'left' then
					v.x = x
				elseif self.horizontal_align == 'right' then
					v.x = width_remaining
				end
			end
			width_remaining = width_remaining - v.width
		end

		if not v.y then
			if v.display == 'inline' then
				if self.vertical_align == 'middle' then
					v.y = v.y + (self.height - v.height) / 2
				elseif self.vertical_align == 'bottom' then
					v.y = v.y + (self.height - v.height)
				end
			end
		end

	end
end
