LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager:new(text_renderer)
	assert(text_renderer)
	local obj = {
		text_renderer = text_renderer
	}
	obj.contexts = {}
	setmetatable(obj, LayoutManager)
	return obj
end

function LayoutManager:position(context, e)
	assert(context)
	assert(e)

	if e.left then
		e.x = e.left
	end

	if e.top then
		e.y = e.top
	end

	if e.right then
		if not e.left then
			e.x = context.width - e.width - e.right
		end
	end

	if e.bottom then
		if not e.top then
			e.y = context.height - e.height - e.bottom
		end
	end

	if e.horizontal_align == 'left' then
		e.x = 0
	elseif e.horizontal_align == 'center' then
		e.x = (context.width - e.width) / 2
	elseif e.horizontal_align == 'right' then
		e.x = context.width - e.width
	end

	e.y = e.y or 0
	e.x = e.x or 0
end

function LayoutManager:absolute_position(e)
	local absolute_x = e.x
	if e.parent then
		absolute_x = absolute_x + e.parent.absolute_x + e.parent.offset_x
	end
	e.absolute_x = absolute_x

	-- Calculate Y
	local absolute_y = e.y
	if e.parent then
		absolute_y = absolute_y + e.parent.absolute_y + e.parent.offset_y
	end
	e.absolute_y = absolute_y

	-- Set Coordinates
	local top_left = {
		x = e.absolute_x,
		y = e.absolute_y
	}

	local top_right = {
		x = e.absolute_x + e.width - 1,
		y = e.absolute_y
	}

	local bottom_left = {
		x = e.absolute_x,
		y = e.absolute_y + e.height - 1
	}

	local bottom_right = {
		x = e.absolute_x + e.width - 1,
		y = e.absolute_y + e.height - 1
	}
	-- add parent offset
	e.absolute_coords = {
		top_left = top_left,
		top_right = top_right,
		bottom_left = bottom_left,
		bottom_right = bottom_right
	}
end

function LayoutManager:width(context, e)
	if e.left and e.right then
		e.width = context.width - e.right - e.left
	elseif not e.width then
		e.width = context.width
	end
end

function LayoutManager:height(context, e)
	-- Calculate height
	if e.top and e.bottom then
		e.height = context.height - e.top - e.bottom
	elseif not e.height then
		e.height = context.height
		if e.text then
			self.text_renderer:calculate_text(e, e.adjusted_width)
			e.height = e.line_height * # e.lines_of_text + e.padding_top
				+ e.padding_bottom + e.border_width * 2
		end
	end
end

function LayoutManager:adjusted_height(e)
	-- Calculate adjusted height
	e.adjusted_height = e.height -
		e.padding_top -
		e.padding_bottom -
		e.border_width * 2
end

function LayoutManager:adjusted_width(e)
	-- Calculate adjusted width
	e.adjusted_width = e.width -
		e.padding_left -
		e.padding_right -
		e.border_width * 2
end

function LayoutManager:offsets(e)
	e.offset_x = e.border_width + e.padding_left
	e.offset_y = e.border_width + e.padding_top
end

local function add_parent_val(e, prop, x)
	if e.parent then
		x.count = x.count + e.parent[prop]
		x.count = x.count + e.parent['offset_' .. prop]
		add_parent_val(e.parent, prop, x)
	else
		return x
	end
end

function LayoutManager:clip_position(e)
	local x_count = { count = e.x }
	local y_count = { count = e.y }
	add_parent_val(e, 'x', x_count)
	add_parent_val(e, 'y', y_count)
	e.clip_x = x_count.count
	e.clip_y = y_count.count
end

function LayoutManager:adjusted_position(e)
	e.adjusted_x = e.x + e.offset_x
	e.adjusted_y = e.y + e.offset_y
end

function LayoutManager:layout(e)
	local context = {
		height = e.parent and e.parent.adjusted_height or GraphicsHeight(),
		width = e.parent and e.parent.adjusted_width or GraphicsWidth()
	}
	self:width(context, e)
	self:adjusted_width(e)
	self:height(context, e)
	self:adjusted_height(e)
	self:offsets(e)
	self:position(context, e)
	self:clip_position(e)
	self:absolute_position(e)
end
