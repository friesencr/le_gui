local c = Gui.util.get_value

BackgroundRenderer = {}
BackgroundRenderer.__index = BackgroundRenderer

function BackgroundRenderer:new()
	local obj = {}
	setmetatable(obj, BackgroundRenderer)
	return obj
end

function BackgroundRenderer:draw_background_color(e)
	if e.background_color then
		SetColor(c(e.background_color, e))
		DrawRect(
			0 + c(e.border_width, e),
			0 + c(e.border_width, e),
			c(e.width, e) - c(e.border_width, e) * 2,
			c(e.height, e) - c(e.border_width, e) * 2
		)
	end
end

function BackgroundRenderer:draw_background_image(e)
	if e.background_image then
		SetColor(Vec4(1,1,1,1))
		DrawImage(LoadTexture(c(e.background_image, e)),
			0,
			0,
			c(e.width, e),
			c(e.height, e)
		)
	end
end
