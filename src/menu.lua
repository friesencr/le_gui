AppLog('gui - initializing menu')

local Menu = {
	defaults = {
		name = 'menu',
		max_display_count = false, -- a number
		calculated_height = nil
	}

	, add_menu_item = function(self, ...)
		local menu_items = {...}
		for i,v in ipairs(menu_items) do
			table.insert(self.menu_items, v)
			self:add_child(v)
			v.index = #self.menu_items
		end
	end

	, remove_menu_item = function(self, ...)
		local menu_items = {...}
		for i,v in ipairs(menu_items) do
			for a,b in ipairs(self.menu_items) do
				if v == b then
					v:free()
					self.menu_items[a] = nil
				end
			end
		end
	end

	, on_select = function(self, e)
		if self.selected_item ~= e.target and self.selected_value ~= e.target.value then
			self.selected_value = e.target.value
			self.selected_item = e.target
			for i,v in ipairs(self.menu_items) do
				if v == e.target then
					v:change_state('selected')
				else
					v:change_state('unselected')
				end
			end
			self:trigger('change')
		end
	end

	, on_pre_render = function(self)
		if self.do_calculate_height and not self.calculated_height then
			local height = 0
			local index = #self.menu_items
			self.styles.top = (index - 1) * 35
			if self.max_display_count and index > self.max_display_count then index = self.max_display_count end
			height = self.menu_items[index].relative_coords.bottom_left.y
			height = height + self.border_width * 2 + self.padding_top + self.padding_bottom + 1
			self.styles.height = height
			self.calculated_height = height
		end
	end

	, select = function(menu_item_or_index)
		local y = type(menu_item_or_index)
		local item
		if y == 'number' then
			item = self.menu_items[menu_item_or_index]
		else
			for i,v in ipairs(self.menu_items) do
				if v == menu_item_or_index then 
					item = v 
				end
			end
		end
		if item then
			item:select()
		end
	end
}

function Menu:new(options)
	local obj = Gui.Element(options)
	obj.menu_items = {}
	obj:merge(Menu.defaults, Menu, options)
	obj:on('select', obj.on_select)
	obj:on('pre_render', obj.on_pre_render)
	obj:initialize()
	if not obj.height then
		obj.do_calculate_height = true
	end
	return obj
end

setmetatable(Menu, { __call = function(x, ...) return Menu:new(...) end })

Gui.Menu = Menu
