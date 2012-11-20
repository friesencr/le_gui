local c = Gui.util.get_value

BorderRenderer = {}
BorderRenderer.__index = BorderRenderer

function BorderRenderer:new()
	local obj = {}
	setmetatable(obj, BorderRenderer)
	return obj
end

function BorderRenderer:draw_border(e)
	if e.border_width > 0 then
		assert(e.border_color)
		SetColor(c(e.border_color, e))

		local top_left = { x = 0, y = 0 }
		local top_right = { x = c(e.width, e) - 1, y = 0 }
		local bottom_left = { x = 0, y = e.height-1 }
		local bottom_right = { x = c(e.width, e) - 1, y = c(e.height, e) - 1 }

		for width = 0, e.border_width - 1 do

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
