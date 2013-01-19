local icons = Gui.Element({
	name = 'fonts',
	styles = {
		top = 0,
		bottom = 0,
		left = 0,
		right = 0,
	}
})
local width = 50
local index = 0
index = index + 1
-- local icon = Gui.Element({
-- 	styles = {
-- 		background_image = Gui.font_awesome:get(1),
-- 		height = 50,
-- 		width = 50,
-- 		top = 50,
-- 		left = 50
-- 	}
-- })
for k,v in pairs(Gui.font_awesome.icons) do
	index = index + 1
	local icon = Gui.Element({
		style = {
			-- background_image = Gui.font_awesome(k),
			height = 50,
			width = 50,
			-- left = function(x) return (index % math.floor(index / icons.adjusted_width / 60)) * 60 end,
			-- top = function(x) return math.floor(index / (icons.adjusted_width / 60)) * 60 end
		}
	})
	icons:add_child(icon)
end
demo_region:add_child(icons)
