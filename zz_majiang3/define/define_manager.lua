mrequire("mapping.register_key_name")
mrequire("mapping.register_name_alias")
mrequire("mapping.register_name_key")

DefineManager = class("DefineManager")

function DefineManager:ctor()
	self.name_key_dict = {}
	self.key_name_dict = {}
	self.name_alias_dict = {}
end

function DefineManager:initialize()
	
end

function DefineManager:get_index_by_name(name)
	return mapping.register_name_key.name_key_dict[name]
end

function DefineManager:get_name_by_index(index)
	return mapping.register_key_name.key_name_dict[index]
end

function DefineManager:get_alias_by_name(name)
	return mapping.register_name_alias.name_alias_dict[name]
end