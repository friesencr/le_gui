AppLog('gui - initializing select_box')

local SelectBox = {
	defaults = {
		max_display_count = 7,
		calculated_height = nil
	}

	, add_select_box_item = function(self, ...)
		local select_box_items = {...}
		for i,v in ipairs(select_box_items) do
			table.insert(self.select_box_items, v)
			self:add_child(v)
			v.index = #self.select_box_items
		end
	end

	, remove_select_box_item = function(self, ...)
		local select_box_items = {...}
		for i,v in ipairs(select_box_items) do
			for a,b in ipairs(self.select_box_items) do
				if v == b then
					v:free()
					self.select_box_items[a] = nil
				end
			end
		end
	end

	, on_select = function(self, e)
		if self.selected_item ~= e.target and self.selected_value ~= e.target.value then
			self.selectd_value = e.target.value
			self.selected_item = e.target
			for i,v in ipairs(self.select_box_items) do
				if v == e.target then
					v:change_state('selected')
				else
					v:change_state('unselected')
				end
			end
			self:trigger('changed')
		end
	end

	, on_pre_render = function(self)
		if self.do_calculate_height and not self.calculated_height then
			local height = 0
			local index = #self.select_box_items
			if index > self.max_display_count then index = self.max_display_count end
			height = self.select_box_items[index].relative_coords.bottom_left.y
			height = height + self.offset_y * 2 + 1
			self.styles.height = height
			self.calculated_height = height
		end
	end

	, select = function(select_box_item_or_index)
		local y = type(select_box_item_or_index)
		local item
		if y == 'number' then
			item = self.select_box_items[select_box_item_or_index]
		else
			for i,v in ipairs(self.select_box_items) do
				if v == select_box_item_or_index then 
					item = v 
				end
			end
		end
		if item then
			item:select()
		end
	end
}

function SelectBox:new(options)
	local obj = Gui.Element(options)
	obj.select_box_items = {}
	obj:merge(SelectBox.defaults, SelectBox, options)
	obj:on('select', obj.on_select)
	obj:on('pre_render', obj.on_pre_render)
	obj:initialize()
	if not obj.height then
		obj.do_calculate_height = true
	end
	return obj
end

setmetatable(SelectBox, { __call = function(x, ...) return SelectBox:new(...) end })

Gui.SelectBox = SelectBox
