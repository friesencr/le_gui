BackgroundRenderer = {}
BackgroundRenderer.__index = BackgroundRenderer

function BackgroundRenderer:new()

end

function BackgroundRenderer:draw_background_color()
	if self.background_color then
		SetColor(self.background_color)
		DrawRect(
			0 + self.border_width,
			0 + self.border_width,
			self.width - self.border_width * 2,
			self.height - self.border_width * 2
		)
	end
end

function BackgroundRenderer:draw_background_image()
	if self.background_image then
		DrawImage(self.background_image,
			0,
			0,
			self.width,
			self.height
		)
	end
end
