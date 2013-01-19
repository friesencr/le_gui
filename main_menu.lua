local menu = Gui.Menu{
	name = 'main_menu',
	max_display_count = false,
	styles = {
		right = 0
	}
}
menu:add_menu_item(Gui.MenuItem({ text = "Menu", value = 'menu'}))
menu:add_menu_item(Gui.MenuItem({ text = "Text Boxes", value = 'textboxes'}))
menu:add_menu_item(Gui.MenuItem({ text = "Checkbox", value = 'checkboxes'}))
menu:add_menu_item(Gui.MenuItem({ text = "Select Box", value = 'selectboxes'}))
menu:add_menu_item(Gui.MenuItem({ text = "Panel", value = 'panel'}))
menu:add_menu_item(Gui.MenuItem({ text = "Tabs", value = 'tabs'}))
menu:add_menu_item(Gui.MenuItem({ text = "Accordian", value = 'accordian'}))
menu:add_menu_item(Gui.MenuItem({ text = "Scrollbars", value = 'scrollbars'}))
menu:add_menu_item(Gui.MenuItem({ text = "Font Awesome", value = 'font_awesome'}))

menu:on('change', function(self, e)
	demo_region:clear()
	dofile("lib/le_gui/".. self.selected_value .. ".lua")
end, nil, menu)
