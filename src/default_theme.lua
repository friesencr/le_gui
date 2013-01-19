AppLog('gui - applying default styles')
local primary_color = Vec4(0,.8,0,1)
local primary_color_accent = Vec4(0,1,0,1)
local secondary_color = Vec4(0, .5, .5, 1)
local secondary_color_accent = Vec4(0, .7, .7, 1)
local background_color = Vec4(.2,.2,.2,1)
local background_color_accent = Vec4(.1, .1, .1, 1)
local border_width = 1
local border_color = Vec4(.7,.7,.7,1)
local control_padding = {
	padding_top = 5,
	padding_bottom = 5,
	padding_left = 10,
	padding_right = 10,
}
local panel = {
	border_width = border_width,
	border_color = border_color,
	background_color = background_color
}
local btn = {
	border_width = border_width,
	border_color = border_color
}
local btn_hover = {
	background_color = primary_color_accent
}
local vertical_menu = {
	width = 150,
	padding_top = 5,
	padding_bottom = 5,
	padding_left = 5,
	padding_right = 5,
	clip = true
}
local list_item = {
	border_width = border_width,
	border_color = border_color,
	background_color = background_color_accent,
	height = 30,
	width = 138
}
local vertical_list_item = {
	top = function(x) return (x.index - 1) * 35 end
}
local list_item_selected = {
	background_color = secondary_color_accent
}
local list_item_hover = {
	background_color = secondary_color_accent
}
local scrollbar = {
	border_width = border_width,
	border_color = border_color,
	background_color = background_color
}
local vertical_scrollbar = {
	width = 20,
	right = 0,
	top = 0,
	bottom = 0
}
local horizontal_scrollbar = {
	bottom = 0,
	height = 20,
	left = 0,
	right = 0
}
local scroll_knob = {
	height = 18,
	width = 18,
	background_color = background_color_accent
}
local arrow = {
	height = 18,
	width = 18
}
local top_arrow = {
	top = 0,
	background_image = Gui.font_awesome['arrow-up']
}
local bottom_arrow = {
	bottom = 0,
	background_image = Gui.font_awesome['arrow-down']
}
local right_arrow = {
	right = 0,
	background_image = Gui.font_awesome['arrow-right']
}
local left_arrow = {
	left = 0,
	background_image = Gui.font_awesome['arrow-left']
}

Gui.Button.defaults.class = { btn }
Gui.Button.defaults.state = { hover = btn_hover }
Gui.Menu.defaults.class = { panel, vertical_menu }
Gui.Menu.defaults.state = { }
Gui.MenuItem.defaults.class = { list_item, vertical_list_item, control_padding }
Gui.MenuItem.defaults.state = { selected = list_item_selected, hover = list_item_hover }
Gui.Scrollable.scrollbar_x_defaults.class = { scrollbar, scrollbar_x }
Gui.Scrollable.scrollbar_x_defaults.state = {}
Gui.Scrollable.scrollbar_y_defaults.class = { scrollbar, scrollbar_y }
Gui.Scrollable.scrollbar_y_defaults.state = {}
Gui.Scrollable.scrollbar_knob_defaults.class = { scollbar_knob }
Gui.Scrollable.scrollbar_knob_defaults.state = {}
Gui.Scrollable.scrollbar_up_arrow_defaults.class = { arrow, top_arrow }
Gui.Scrollable.scrollbar_up_arrow_defaults.state = {}
Gui.Scrollable.scrollbar_down_arrow_defaults.class = { arrow, down_arrow }
Gui.Scrollable.scrollbar_down_arrow_defaults.state = {}
Gui.Scrollable.scrollbar_right_arrow_defaults.class = { arrow, right_arrow }
Gui.Scrollable.scrollbar_right_arrow_defaults.state = {}
Gui.Scrollable.scrollbar_left_arrow_defaults.class = { arrow, left_arrow }
Gui.Scrollable.scrollbar_left_arrow_defaults.state = {}
