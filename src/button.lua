AppLog('gui - initializing button')

local Button = {

	defaults = {

	}

	, on_click = function(self, e)

	end

}


function Button:new(options)
	local obj = Gui.Control(options)
	obj:merge(Button.defaults)
	obj:on('click', obj.on_click, nil, obj)
	return obj
end

setmetatable(Button, { __call = function(x, ...) return Menu:new(...) end })

Gui.Button = Button
