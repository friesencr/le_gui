LayoutManager = {}
LayoutManager.__index = {}

function LayoutManager:new()
	local obj = {}
	obj.contexts = {}
	setmetatable(obj, LayoutManager)
	return obj
end

function LayoutManager:get_context(parent)
	local id = (parent and parent._identity) or 0
	local context = self.contexts[id] 
	if not context then
		context = RenderContext:new(parent)
		self.contexts[id] = context
	end
	return context
end

function LayoutManager:position(context, element)
	if element.display == 'inline' then
		local fits = context:current_row():add_inline_item(child)
		if not fits then
			context:add_row():add_inline_item(element)
		end
	elseif element.display == 'block' then
		context:add_row():add_block_item(element)
	end
end

function LayoutManager:absolute_position(e)
	local absolute_x = e.x + alignment_offset_x
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
	if not e.width then
		e.width = context.width
		if e.dispaly == "inline" and e.text then
			local text_width = TextWidth(e.text) + e.padding_left + 
				e.padding_right + e.border_width * 2

			if text_width < parent_width then
				e.width = text_width
			end
		end
	end
end

function LayoutManager:height(context, e)
	-- Calculate height
	if not e.height then
		e.height = context.height
		if e.text then
			e:calculate_text(e.adjusted_width)
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

function LayoutManager:adjusted_position(e)
	e.adjusted_x = e.x + e.offset_x
	e.adjusted_y = e.y + e.offset_y
end

function LayoutManager:layout(e)
	local context = self:get_context(e.parent)
	self:width(context, e)
	self:adjusted_width(e)
	self:height(context, e)
	self:adjusted_height(e)
	self:offsets(e)
	self:position(e)
	self:absolute_position(e)
end
