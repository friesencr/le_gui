local Animatable = {

	fade_in = function(self, duration, easing, callback)
		callback = callback or Gui.noop
		if self:is_hidden() then
			self.styles.opacity = 0
			self:show()
			return self:animate(
				duration or 400,
				{ opacity = 1 },
				easing,
				function() callback() end
			)
		else
			return false
		end
	end

	, fade_out = function(self, duration, easing, callback)
		callback = callback or Gui.noop
		if not self:is_hidden() then
			return self:animate(
				duration or 400,
				{ opacity = 0 },
				easing,
				function() self:hide(); callback() end
			)
		else
			return false
		end
	end

	-- , slide_out = function(self, duration, easing, callback)
	-- 	callback = callback or Gui.noop
	-- 	if not self:is_hidden() then
	-- 		self.styles.opacity = 0
	-- 		return self:animate(
	-- 			duration or 400,
	-- 			{ opacity = 0 },
	-- 			easing,
	-- 			function() self:hide(); callback() end
	-- 		)
	-- 	else
	-- 		return false
	-- 	end
	-- end

	, animate = function(self, duration, target, easing, callback)
		for k,v in pairs(target) do
			self.styles[k] = self[k]
		end
		return Gui.animate(duration, self.styles, target, easing, callback)
	end

}

Gui.Animatable = Animatable
