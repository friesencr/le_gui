BorderRenderer = {}
BorderRenderer.__index = BorderRenderer

function BorderRenderer:new()

end

function BorderRenderer:draw_border()
	-- print_table(self)
	assert(self.border_color)
	SetColor(self.border_color)
	if self.border_width > 0 then

		local top_left = { x=0, y=0 }
		local top_right = { x=self.width-1, y=0 }
		local bottom_left = { x=0, y=self.height-1 }
		local bottom_right = { x=self.width-1, y=self.height-1 }

		for width = 0, self.border_width - 1 do

			-- top border
			DrawLine(
				top_left.x + width,
				top_left.y + width,
				top_right.x - width,
				top_right.y + width)

			-- right border
			DrawLine(
				top_right.x - width,
				top_right.y + width +1,
				bottom_right.x - width,
				bottom_right.y - width -1)

			-- bottom border
			DrawLine(
				bottom_right.x - width,
				bottom_right.y - width,
				bottom_left.x + width,
				bottom_left.y - width)

			-- left border
			DrawLine(
				bottom_left.x + width,
				bottom_left.y - width -1,
				top_left.x + width,
				top_left.y + width +1)

		end
	end
end
