TextRenderer = {}
TextRenderer.__index = TextRenderer

function TextRenderer:new()

end

function TextRenderer:draw_text()
	if self.font then
		SetFont(self.font)
	end
	if self.text then
		assert(self.color)
		SetColor(self.color)
		-- only calculate if needed
		-- render text
		for y,line in ipairs(self.lines_of_text) do
			local x_offset = 0
			-- adjust for center align
			if self.text_align == 'center' then
				x_offset = (self.adjusted_width - line.width) / 2
			-- adjust for right align
			elseif self.text_align == 'right' then
				x_offset = (self.adjusted_width - line.width)
			end
			-- render every word on line
			for i, word in ipairs(line) do
				DrawText(word.text,
					word.x + self.offset_x + x_offset + self.text_offset_x,
					((y - 1) * self.line_height) + self.offset_y + self.text_offset_y
				)
			end
		end
	end
end

function TextRenderer:calculate_text()
	if not self.text then do return end end
	if not compare_tables(self.text_cache, { self.text, width }) then
		local words = str_split(self.text, ' ')
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
			self.lines_of_text = lines
			self.text_cache = {
				self.text,
				width
			}
		end
	end
end
