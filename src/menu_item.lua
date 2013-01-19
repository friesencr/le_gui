AppLog('gui - initializing menu item')

local MenuItem = {

	defaults = {
		name = 'menu_item'
	}

	, change_state = function(self, state)
		if state == 'selected' then
			for i,v in ipairs(self:find_self_or_children()) do
				v:add_state('selected')
				v:remove_state('unselected')
			end
		elseif state == 'unselected' then
			for i,v in ipairs(self:find_self_or_children()) do
				v:add_state('unselected')
				v:remove_state('selected')
			end
		end
	end

	, enable = function(self)
		self.disabled = false
	end

	, disable = function(self)
		self.disabled = true
	end

	, select = function(self)
		self:trigger('select')
	end

	, deselect = function(self)
		self:trigger('deselect')
	end
}

function MenuItem:new(options)
	assert(options)
	assert(options.value)
	if not options.text then
		options.text = options.value
	end
	local obj = Gui.Control(options)
	obj:merge(MenuItem.defaults, MenuItem, options)
	obj:initialize()
	obj:on('click', obj.select, nil, obj)
	return obj
end

setmetatable(MenuItem, { __call = function(x, ...) return MenuItem:new(...) end })

Gui.MenuItem = MenuItem
