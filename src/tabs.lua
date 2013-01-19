local Tab = {

	default_tab_styles = {}

	, change_state

	, select = function()

	end
	
	,

}

function Tab:new(title, content)

end

local Tabs = {
	
	defaults = {
		selected_index = nil,
		selected_tab = nil
	}

	, select = function(self, tab_or_tab_index)
		assert(tab_or_tab_index)
		local t = type(tab_or_tab_index)
		if t == 'table' then

		else

		end
	end

	, add_tab = function(self, tab)

	end

}

function Tabs:new(options)
	local obj Gui.Element(options)
	return obj
end

Gui.Tabs = Tabs
Gui.Tab = Tab
