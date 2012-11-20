local Control = {

	capture_events = function(self, hit)
		if self.mouse_in then
			if hit == false and Gui.last_mouse_element == self then
				self.mouse_in = false
				self:trigger('mouseout')
				Gui.last_mouse_element = nil
			end
		elseif hit then
			self.mouse_in = true
			self:trigger('mousein')
			Gui.last_mouse_element = self
		end

		if hit then
			local clipping_parent = self:get_clip_parent()
			if clipping_parent then
				local parent_hit = Gui.hit_test(
					MouseX(),
					MouseY(),
					clipping_parent.absolute_coords.top_left.x,
					clipping_parent.absolute_coords.top_left.y,
					clipping_parent.absolute_coords.bottom_right.x,
					clipping_parent.absolute_coords.bottom_right.y
				)
				hit = parent_hit
			end
		end

		if hit then
			if Gui.events.mouse_down[MOUSE_LEFT] then
				Gui.last_mouse_down = self
			elseif Gui.events.mouse_down[MOUSE_RIGHT] then
				Gui.last_mouse_down = self
			elseif Gui.events.mouse_down[MOUSE_MIDDLE] then
				Gui.last_mouse_down = self
			end
		end

		if hit and Gui.last_mouse_down == self then
			if Gui.events.mouse_up[MOUSE_LEFT] then
				self:trigger('click', { button = MOUSE_LEFT } )
			elseif Gui.events.mouse_up[MOUSE_RIGHT] then
				self:trigger('click', { button = MOUSE_RIGHT } )
			elseif Gui.events.mouse_up[MOUSE_MIDDLE] then
				self:trigger('click', { button = MOUSE_MIDDLE } )
			end
		end
	end
}

setmetatable(Control, { __call = function(x, ...) return Control:new(...) end })

function Control:new(values)
	values = values or {}
	local obj = Gui.Element(values)
	Gui.util.table_merge(obj, Control)
	obj.eventable = true
	obj.new = nil
	return obj
end

Gui.Control = Control

