local Scrollable = {

	defaults = {

	}

	, scrollbar_x_defaults = { name = 'scrollbar_x' }
	, scrollbar_y_defaults = { name = 'scrollbar_y' }
	, scrollbar_knob_defaults = { name = 'scroll_knob' }
	, scrollbar_up_arrow_defaults = { name = 'up_arrow' }
	, scrollbar_down_arrow_defaults = { name = 'down_arrow' }
	, scrollbar_right_arrow_defaults = { name = 'right_arrow' }
	, scrollbar_left_arrow_defaults = { name = 'left_arrow' }

	, calculate_scrollbars = function(self)

		if self.clip then

			local max_right, max_bottom

			-- calculate horizontal scrollbar
			-- AppLog('adj' .. self.adjusted_width)
			-- AppLog('inner' .. self.inner_width)
			if self.scroll_x and self.adjusted_width < self.inner_width then
				if not self.scrollbar_x then
					self:create_scrollbar_x()
				end
				self.scrolling_x = true
			else
				if self.scrollbar_x then
					self.scrollbar_x:destroy()
					self.scrollbar_x = nil
				end
				self.scrolling_x = false
			end

			-- calculate vertical scrollbar
			if self.scroll_y and self.adjusted_height < self.inner_height then
				if not self.scrollbar_y then
					self:create_scrollbar_y()
				end
				self.scrolling_y = true
			else
				if self.scrollbar_y then
					self.scrollbar_y:destroy()
					self.scrollbar_y = nil
				end
				self.scrolling_y = false
			end

		end
	end

	, on_scrollbar_click = function(self, e)

	end

	, on_scrollbar_click = function(self, e)

	end

	, render_scrollbar = function(self, e)

	end

}

function Scrollable:create_scrollbar_x()
	local scrollbar = Gui.Control(Scrollable.scrollbar_x_defaults)
	-- local right_arrow = Gui.Control(Scrollable.scrollbar_right_arrow_defaults)
	-- local left_arrow = Gui.Control(Scrollable.scrollbar_left_arrow_defaults)
	-- local knob = Gui.Control(Scrollable.scrollbar_knob_defaults)
	-- scrollbar:add_children{ right_arrow, left_arrow, knob }
	scrollbar:set_parent(self)
	self.scrollbar_x = scrollbar
end

function Scrollable:create_scrollbar_y()
	local scrollbar = Gui.Control(Scrollable.scrollbar_y_defaults)
	-- local top_arrow = Gui.Control(Scrollable.scrollbar_up_arrow_defaults)
	-- local bottom_arrow = Gui.Control(Scrollable.scrollbar_down_arrow_defaults)
	-- local knob = Gui.Control(Scrollable.scrollbar_knob_defaults)
	-- scrollbar:add_children{ top_arrow, bottom_arrow, knob }
	scrollbar:set_parent(self)
	self.scrollbar_y = scrollbar
end

Gui.Scrollable = Scrollable
