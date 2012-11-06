BackgroundRenderer = {}
BackgroundRenderer.__index = BackgroundRenderer

function BackgroundRenderer:new()
	local obj = {}
	setmetatable(obj, BackgroundRenderer)
	return obj
end

function BackgroundRenderer:draw_background_color(e)
	if e.background_color then
		SetColor(e.background_color)
		DrawRect(
			0 + e.border_width,
			0 + e.border_width,
			e.width - e.border_width * 2,
			e.height - e.border_width * 2
		)
	end
end

function BackgroundRenderer:draw_background_image(e)
	if e.background_image then
		DrawImage(e.background_image,
			0,
			0,
			e.width,
			e.height
		)
	end
end
