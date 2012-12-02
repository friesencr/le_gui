local c = Gui.util.get_value

TextRenderer = {}
TextRenderer.__index = TextRenderer

function TextRenderer:new()
	local obj = {}
	setmetatable(obj, TextRenderer)
	return obj
end

function TextRenderer:draw_text(e)
	self:calculate_text(e, e.adjusted_width)
	if e.font then
		SetFont(LoadFont(e.font))
	end
	if e.text then
		assert(e.color)
		SetColor(c(e.color, e))
		-- only calculate if needed
		-- render text
		for y,line in ipairs(e.lines_of_text) do
			local x_offset = 0
			-- adjust for center align
			if c(e.text_align, e) == 'center' then
				x_offset = (e.adjusted_width - line.width) / 2
			-- adjust for right align
			elseif c(e.text_align, e) == 'right' then
				x_offset = (e.adjusted_width - line.width)
			end
			-- render every word on line
			for i, word in ipairs(line) do
				DrawText(word.text,
					word.x + x_offset + e.text_offset_x,
					((y - 1) * e.line_height) + e.text_offset_y
				)
			end
		end
	end
end

function TextRenderer:calculate_text(e, width)
	assert(e)
	assert(width)
	if not e.text then do return end end
	if not Gui.util.compare_tables(e.text_cache, { c(e.text, e), width }) then
		local words = Gui.util.str_split(c(e.text, e), ' ')
		local text_x = 0
		local lines = {
			word_count = 0
		}
		local line = {}
		table.insert(lines, line)

		for i,v in ipairs(words) do
			local text = v
			if # line > 0 then
				-- add space if its not the first word
				text = ' ' .. v
			end

			-- calculate width
			local text_width = TextWidth(text)

			-- if it doesnt fit on the line create a new line
			if text_x + text_width > width then
				text_x = 0
				text = v
				text_width = TextWidth(text)
				line = {}
				table.insert(lines, line)
			end

			-- insert calculated word in line
			table.insert(line, {
				text = text,
				x = text_x,
				text_width = text_width,
			})

			line.width = (line.width or 0) + text_width

			-- set the x position for the next word
			text_x = text_x + text_width
			e.lines_of_text = lines
			e.text_cache = {
				c(e.text, e),
				width
			}
		end
	end
end
