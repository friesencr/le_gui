local Panel = {

	default_options = {
		title_text = false
	}

	, default_title_bar = {}
	, default_title = {}
	, default_close_button = {}
	, default_content = {}

	, close = function(self, e)
		self:hide()
	end

	, open = function(self, e)
		self:show()
	end

}

function Panel:new(options)
	local obj = Gui.Element(name)
	obj:merge(Panel.default_options, options)
	obj:initialize()

	if not obj.title_bar then
		obj.title_bar = Gui.Element('title_bar', Panel.default_title_bar)
	end

	if not obj.title_text or not obj.title then
		obj.title = Gui.Element('title', Panel.default_title)
	end

	if not obj.close_button then
		obj.close_button = Gui.Element('close', Panel.default_close_button)
	end

	if not obj.content then
		obj.content = Gui.Element('content', Panel.default_content)
	end

	obj:add_children{obj.title_bar, obj.content}
	if obj.title then
		obj.title_bar:add_child(obj.title)
	end
	obj.title_bar:add_child(obj.close_button)

	obj.close_button:on('click', function(sender, e)
		obj.close()
	end)

	return obj
end

setmetatable(Menu, { __call = function(x, ...) return Menu:new(...) end })

Gui.Panel = Panel




