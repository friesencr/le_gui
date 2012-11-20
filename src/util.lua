local util = {

	print_table = function(obj)
		AppLog(table.ToString(obj, 'table', true)) 
	end

	, print_args = function(...)
		local arg = {...}
		_.each(arg, function(x) AppLog(x) end)
		return unpack(arg)
	end

	, table_merge = function(dest, ...)
		local args = {...}
		for i,source in ipairs(args) do
			for k,v in pairs(source) do
				dest[k] = v
			end
		end
		return dest
	end

	, compare_tables = function(a, b)
		local same = true
		if a == b then same = true
		elseif (a and not b) or (not a and b) then  same = false 
		elseif (#a ~= #b) then same = false
		else
			for i,v in ipairs(b) do
				same = a[i] == v
				if not same then break end
			end
		end
		return same
	end

	, str_split = function(str, sSeparator, nMax, bRegexp)
		assert(str)
		assert(sSeparator ~= '')
		assert(nMax == nil or nMax >= 1)

		local aRecord = {}

		if str:len() > 0 then
			local bPlain = not bRegexp
			nMax = nMax or -1

			local nField=1 nStart=1
			local nFirst,nLast = str:find(sSeparator, nStart, bPlain)
			while nFirst and nMax ~= 0 do
				aRecord[nField] = str:sub(nStart, nFirst-1)
				nField = nField+1
				nStart = nLast+1
				nFirst,nLast = str:find(sSeparator, nStart, bPlain)
				nMax = nMax-1
			end
			aRecord[nField] = str:sub(nStart)
		end

		return aRecord
	end

	, get_value = function(val, arg)
		local t = type(val)
		if t == 'function' then
			return val(arg)
		else
			return val
		end
	end

}

Gui.util = util
