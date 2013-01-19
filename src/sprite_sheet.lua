local SpriteSheet = {

	get_texture_by_index = function(self, index)
		local column = (self.columns / (index - 1)) % self.columns
		local row = self.rows / (index - 1)
		return self:get_texture_by_column_and_row(column, row)
	end

	, get_texture_by_column_and_row = function(self, column, row)
		local cache_key = column .. '.' .. row
		local cache = self.icon_cache[cache_key]
		if cache then
			return cache
		else
			local x = column * self.icon_width
			local y = row * self.icon_height
			SetBuffer(self.icon_buffer)
			SetColor(Vec4(0,0,0,0))
			ClearBuffer(BUFFER_COLOR)
			SetColor(Vec4(1,1,1,1))
			DrawImage(self.super_texture, x, -y, self.texture_width, self.texture_height)
			local texture = GetColorBuffer(self.icon_buffer)
			self.icon_cache[cache_key] = texture
			return texture
		end
	end

	, get = function(self, index_or_column, row)
		if not row then
			return self:get_texture_by_index(index_or_column)
		else
			return self:get_texture_by_column_and_row(index_or_column, row)
		end
	end

	, free = function(self)
		for i,v in pairs(self.icon_cache) do
			v:Free()
		end
	end
}

function SpriteSheet:new(options)
	local obj = options
	assert(options)
	assert(options.asset_path)
	assert(options.icon_height)
	assert(options.icon_width)
	Gui.util.table_merge(obj, SpriteSheet)
	obj.super_texture = LoadTexture(obj.asset_path)
	obj.texture_width = TextureWidth(obj.super_texture)
	obj.texture_height = TextureHeight(obj.super_texture)
	obj.icon_cache = {}
	if not obj.columns then
		obj.columns = math.floor(obj.texture_height / obj.icon_height)
	end
	if not options.rows then
		obj.rows = math.floor(obj.texture_width / obj.icon_width)
	end
	obj.icon_buffer = assert(CreateBuffer(obj.icon_width, obj.icon_height, BUFFER_COLOR))
	return obj
end

setmetatable(SpriteSheet, { __call = function(x, ...) return SpriteSheet:new(...) end })

Gui.SpriteSheet = SpriteSheet
