
CObjectBase = class("CObjectBase")

function CObjectBase:ctor()
	print("----------------CObjectBase:ctor()---------------")
	self.is_ruler = false
	self.is_save = false
	self.module_name = ""
	self.attribute_table = {}
end

function CObjectBase:set_module_name(name)
	-- body
	self.module_name = name
end

function CObjectBase:load_object_data(data_dict)
	if self.is_ruler == true then
		self:create_dynamic_object(data_dict)
	else
		for key,value in pairs(data_dict) do
			local key_index = define.manager:get_index_by_name(key)
			local attribute_data = self.attribute_table[key_index]
			if type(attribute_data) == "table" and key_index ~= nil then
				attribute_data:load_object_data(value)
			else
				self.attribute_table[key_index] = self:check_regular_value(value)	
			end
		end
	end
end

function CObjectBase:check_regular_value(regular_value)
	if type(regular_value) == "table" then
		local translate_value = {}
		for key,value in pairs(regular_value) do
			local to_key = tonumber(key)
		
			if to_key == nil then
				translate_value[key] = value
			else
				translate_value[to_key] = value
			end
		end
		
		return translate_value
	end
	
	return regular_value
end

function CObjectBase:save_object_data()
	local data_dict = {}
	local data_key = nil
	
	for key,value in pairs(self.attribute_table) do
	  
		data_key = define.manager:get_name_by_index(key)
		
		if data_key == nil then
		  data_key = key
		end
		
		if type(value) == "table" and value.attribute_table ~= nil then
			data_dict[data_key] = value:save_object_data()
		else
			data_dict[data_key] = value
		end
	end
	return data_dict
end

function CObjectBase:create_dynamic_object(data_dict)
end

function CObjectBase:initialize()
	self:_do_after_init()
end

function CObjectBase:_do_after_init()
end

function CObjectBase:set_attribute(key,value)
	self.attribute_table[key] = value
	
	self:after_set_attribute(key,value)
	
	-- if self.is_save == true and storage.manager ~= nil then
	-- 	storage.manager:open_need_save()
	-- end
	
	if renovator.manager ~= nil and self.module_name ~= "" then
		renovator.manager:callback_set_object_attr(self.module_name, key, value)
		--renovator.manager:callback_set_module_attr(self.module_name)
	end
end

function CObjectBase:set_attribute_number_value(key,value)
	self:set_attribute(key,tonumber(value))
end

function CObjectBase:after_set_attribute(key,value)
end

function CObjectBase:del_attribute(key)
	self.attribute_table[key] = nil
	
	if self.is_save == true and storage ~= nil and storage.manager ~= nil then
		storage.manager:open_need_save()
	end
	
	if renovator.manager ~= nil and self.module_name ~= "" then
		renovator.manager:callback_set_object_attr(self.module_name, key, value)
	end
end

function CObjectBase:clear_attribute()
	self.attribute_table = {}
	storage.manager:open_need_save()
end

function CObjectBase:get_attribute(key,default)
	local attribute_value = self.attribute_table[key]
	
	if attribute_value ~= nil then
		return attribute_value
	else
		return default
	end
end

function CObjectBase:get_attribute_number_value(key,default)
	default = default or 0
	local value = self.attribute_table[key]
	
	if value == nil then
		return default
	else
		return tonumber(value)
	end
end

function CObjectBase:get_attribute_string_value(key,default)
	default = default or ""
	local value = self.attribute_table[key]
	if value == nil then
		return default
	else
		return tostring(value)
	end
end

function CObjectBase:get_attribute_table_value(key,default)
	default = default or {}
	local value = self.attribute_table[key]
	if value == nil then
		return default
	else
		return value
	end
end

function CObjectBase:increase_attribute_number_value(key,value,source)
	local cur_value = self:get_attribute_number_value(key)
	cur_value = cur_value + value
	self:set_attribute_number_value(key,cur_value)
	
	self:after_increase_attribute_number_value(key,value)
end

function CObjectBase:after_increase_attribute_number_value(key,value,source)
end

function CObjectBase:decrease_attribute_int_value(key, decrease_value, source)
	source = source or ""
	local cur_value = self:get_attribute_number_value(key)
	if cur_value < decrease_value then
		return false
	end
	cur_value = cur_value - decrease_value
	self:set_attribute(key, cur_value)
	self:after_decrease_attribute_number_value(key, decrease_value)
	return true
end

function CObjectBase:after_decrease_attribute_number_value(key,value,source)
end
