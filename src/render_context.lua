RenderContext = {}
RenderContext.__index = RenderContext

function RenderContext:new(parent)
	local obj = {
		id = (parent and parent._identity) or 0,
		items = {},
		parent = parent,
		width = (parent and parent.adjusted_width) or GraphicsWidth(),
		height = (parent and parent.adjusted_height) or GraphicsHeight(),
	}
	setmetatable(obj, RenderContext)
	return obj
end

function RenderContext:add_row()
	self.items[# self.items] = RenderRow:new(self)
end

function RenderContext:current_row()
	local row
	if # self.items == 0 then
		row = RenderRow:new(self)
	else
		row = self.items[# self.items]
	end
	return row
end

function RenderContext:set_positions()
	local accumulative_height = 0
	for i,v in ipairs(self.items) do
		v.set_positions(accumulative_height)
		accumulative_height = v.height
	end
end
