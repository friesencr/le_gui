local _ = Underscore:new()

local function search_children (obj, result, predicate)
	if obj and obj.children and # obj.children > 0 then
		local matches = _.select(obj.children, predicate)
		for i,v in pairs(matches) do
			table.insert(result, v)
		end
		_.each(obj.children, function(x)
				search_children(x, result, predicate)
			end)
	end
end

local function search_parents(obj, result, predicate)
	if obj then
		if predicate(obj) then
			result.value = obj
			return
		else
			search_parents(obj.parent, result, predicate)
		end
	end
end

local ElementList = {

	add_child = function(self, child)
		assert(child)
		child:set_parent(self)
		table.insert(self.children, child)
	end

	, add_children = function(self, children)
		_.each(children, function(x) self:add_child(x) end, self)
	end

	, find_self_or_children = function(self, predicate)
		error 'broken'
		local result = { values = {}}
		predicate = predicate or Gui.true_predicate
		search_parents(self, result, predicate)
		search_children(self, result, predicate)
		return result.values
	end

	, find_children = function(self, predicate)
		local result = { values = {} }
		predicate = predicate or Gui.true_predicate
		search_children(self, result, predicate)
		return result
	end

	, find_self_or_parent = function(self, predicate)
		local result = {}
		predicate = predicate or Gui.true_predicate
		search_parents(self, result, predicate)
		return result.value
	end

	, find_parent = function(self, predicate)
		local result = {}
		predicate = predicate or Gui.true_predicate
		search_parents(self.parent, result, predicate)
		return result.value
	end

}


function ElementList:new()
	local obj = { children = {} }
	Gui.util.table_merge(obj, ElementList)
	obj.new = nil
	return obj
end

setmetatable(ElementList, { __call = function(x, ...) return ElementList:new(...) end })

Gui.ElementList = ElementList
