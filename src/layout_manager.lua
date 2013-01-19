local c = Gui.util.get_value

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
		e.x = c(e.left, e)
	end

	if e.top then
		e.y = c(e.top, e)
	end

	if e.right then
		if not e.left then
			e.x = context.width - c(e.width, c) - c(e.right, e)
		end
	end

	if e.bottom then
		if not e.top then
			e.y = context.height - c(e.height, e) - c(e.bottom, e)
		end
	end

	if e.horizontal_align == 'left' then
		e.x = 0
	elseif e.horizontal_align == 'center' then
		e.x = (context.width - c(e.width, c)) / 2
	elseif e.horizontal_align == 'right' then
		e.x = context.width - c(e.width, c)
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
	e.relative_coords = {
		top_left = {
			x = e.x,
			y = e.y
		},
		top_right = {
			x = e.x + e.width - 1,
			y = e.y
		},
		bottom_left = {
			x = e.x,
			y = e.y + e.height - 1
		},
		bottom_right = {
			x = e.x + e.width - 1,
			y = e.y + e.height - 1
		}
	}
	e.absolute_coords = {
		top_left = {
			x = e.absolute_x,
			y = e.absolute_y
		},
		top_right = {
			x = e.absolute_x + e.width - 1,
			y = e.absolute_y
		},
		bottom_left = {
			x = e.absolute_x,
			y = e.absolute_y + e.height - 1
		},
		bottom_right = {
			x = e.absolute_x + e.width - 1,
			y = e.absolute_y + e.height - 1
		}
	}
end

function LayoutManager:width(context, e)
	if e.left and e.right then
		e.width = context.width - c(e.right, e) - c(e.left, e)
	elseif not e.width then
		e.width = context.width
	end
end

function LayoutManager:height(context, e)
	-- Calculate height
	if e.top and e.bottom then
		e.height = context.height - c(e.top, e) - c(e.bottom, e)
	elseif not e.height then
		e.height = context.height
		if e.text then
			self.text_renderer:calculate_text(e, e.adjusted_width)
			e.height = c(e.line_height, e) * # e.lines_of_text + c(e.padding_top, e)
				+ c(e.padding_bottom, e) + c(e.border_width, e) * 2
		end
	end
end

function LayoutManager:adjusted_height(e)
	-- Calculate adjusted height
	e.adjusted_height = c(e.height, e) - e.offset_height
end

function LayoutManager:adjusted_width(e)
	-- Calculate adjusted width
	e.adjusted_width = c(e.width, e) - e.offset_width
end

function LayoutManager:offsets(e)
	e.offset_x = c(e.border_width, e) + c(e.padding_left, e)
	e.offset_y = c(e.border_width, e) + c(e.padding_top, e)
	e.offset_left = e.offset_x
	e.offset_top = e.offset_y
	e.offset_right = c(e.border_width, e) + c(e.padding_right, e)
	if e.scrolling_x and e.scrollbar_x.initialized then
		self:layout(e.scrollbar_x)
		e.offset_right = e.offset_right + e.scrollbar_x.width
	end
	e.offset_bottom = c(e.border_width, e) + c(e.padding_bottom, e)
	if e.scrolling_y and e.scrollbar_y.initialized then
		self:layout(e.scrollbar_y)
		e.offset_bottom = e.offset_bottom + e.scrollbar_y.height
	end
	e.offset_height = e.offset_top + e.offset_bottom
	e.offset_width = e.offset_left + e.offset_right
end

local function add_parent_val(e, prop, x)
	if e.parent and not e.parent.clip then
		x.count = x.count + c(e.parent[prop], e)
		x.count = x.count + c(e.parent['offset_' .. prop], e)
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
	e.adjusted_x = c(e.x, e) + e.offset_x
	e.adjusted_y = c(e.y, e) + e.offset_y
end

function LayoutManager:inner_sizes(e)
	if not e.initialized then return end
	local max_right, max_bottom = 0, 0
	for i,v in ipairs(e.children) do
		if v.initialized then
			local br = v.relative_coords.bottom_right
			if br.x > max_right then
				max_right = br.x
			end
			if br.y > max_bottom then
				max_bottom = br.y
			end
		end
	end
	e.inner_width = max_right
	e.inner_height = max_bottom
end

function LayoutManager:layout(e)
	if not e.initialized then return end
	local context = {
		height = e.parent and e.parent.adjusted_height or GraphicsHeight(),
		width = e.parent and e.parent.adjusted_width or GraphicsWidth()
	}
	self:offsets(e)
	self:width(context, e)
	self:adjusted_width(e)
	self:height(context, e)
	self:adjusted_height(e)
	self:position(context, e)
	self:clip_position(e)
	self:absolute_position(e)
end
