
RenovatorManager = class("RenovatorManager")

function RenovatorManager:ctor()
	self.renovator_module_reset_func_dict = {}
	self.renovator_attr_reset_func_dict = {}
	self.renovator_attr_remove_func_dict = {}
end

function RenovatorManager:initialize()

end

function RenovatorManager:add_attr_renvator_module_callback(module_name,callback,param)
	local callback_list = self.renovator_module_reset_func_dict[module_name] or {}
	
	for _,exist_callback_data in pairs(callback_list) do
		if callback == exist_callback_data[1] then
			return
		end
	end
	
	table.insert(callback_list,{callback,param})
	
	self.renovator_module_reset_func_dict[module_name] = callback_list
	
	--print("----add_attr_renvator_module_callback = ",callback_list)
end
	
function RenovatorManager:del_attr_renvator_module_callback(module_name, callback)
	local callback_list = self.renovator_module_reset_func_dict[module_name] or {}

	local pop_index = nil
	
	for index,exist_callback_data in pairs(callback_list) do
		if callback == exist_callback_data[1] then
			pop_index = index
		end
	end
	
	if pop_index == nil then
		return
	end
	
	table.remove(callback_list,pop_index)
	
	self.renovator_module_reset_func_dict[module_name] = callback_list
end

--模块-key 添加回调
function RenovatorManager:add_attr_renvator_reset_callback(module_name, attr_key, callback,param)
	local func_dict = self.renovator_attr_reset_func_dict[module_name] or {}
	local callback_list = func_dict[attr_key] or {}
	for _,exist_callback_data in pairs(callback_list) do
		if callback == exist_callback_data[1] then
			return
		end
	end
	
	table.insert(callback_list,{callback,param})
	
	func_dict[attr_key] = callback_list
	self.renovator_attr_reset_func_dict[module_name] = func_dict
end
	
function RenovatorManager:del_attr_renvator_reset_callback(module_name, attr_key, callback)
	local func_dict = self.renovator_attr_reset_func_dict[module_name] or {}
	local callback_list = func_dict[attr_key] or {}
	local pop_index = nil
	
	for index,exist_callback_data in pairs(callback_list) do
		if callback == exist_callback_data[1] then
			pop_index = index
		end
	end
	
	if pop_index == nil then
		return
	end
	
	table.remove(callback_list,pop_index)
	
	func_dict[attr_key] = callback_list
	self.renovator_attr_reset_func_dict[module_name] = func_dict
end
	
function RenovatorManager:add_attr_renvator_remove_callback(module_name, attr_key, callback,param)
	local func_dict = self.renovator_attr_remove_func_dict[module_name] or {}
	local callback_list = func_dict[attr_key] or {}
	for _,exist_callback in pairs(callback_list) do
		if callback == exist_callback then
			return
		end
	end
	
	table.insert(callback_list,callback)
	
	func_dict[attr_key] = callback_list
	self.renovator_attr_remove_func_dict[module_name] = func_dict
end
	
function RenovatorManager:del_attr_renvator_remove_callback(module_name, attr_key, callback)
	local func_dict = self.renovator_attr_remove_func_dict[module_name] or {}
	local callback_list = func_dict[attr_key] or {}
	local pop_index = nil
	
	for index,exist_callback in pairs(callback_list) do
		if callback == exist_callback then
			pop_index = index
		end
	end
	
	if pop_index == nil then
		return
	end
	
	table.remove(callback_list,pop_index)
	func_dict[attr_key] = callback_list
	self.renovator_attr_remove_func_dict[module_name] = func_dict
end

function RenovatorManager:callback_set_module_attr(module_name)
	--print("-------callback_set_module_attr",module_name)
	local func_list = self.renovator_module_reset_func_dict[module_name] or {}
	
	if table.getn(func_list) == 0 then
		--print("---no callback_list")
		return
	end
	
	for _,callback_data in pairs(func_list) do
		local callback_func = callback_data[1]
		local object = callback_data[2]
		--print("------object = ",object:get_layout_name())
		callback_func(object)
	end
end

--模块-key 回调处理
function RenovatorManager:callback_set_object_attr(module_name, attr_key, attr_value)
	--print("-------callback_set_object_attr",module_name,"--" ,attr_key, "--" ,attr_value)
	local func_dict = self.renovator_attr_reset_func_dict[module_name] or {}
	
	local callback_list = func_dict[attr_key] or {}
	if table.getn(callback_list) == 0 then
		--print("---no callback_list")
		return
	end
	
	for _,callback_data in pairs(callback_list) do
		local callback_func = callback_data[1]
		local object = callback_data[2]
		--print("------object = ",object:get_layout_name())
		callback_func(object,attr_key, attr_value)
	end
end

function RenovatorManager:callback_del_object_attr(module_name, attr_key)
	local func_dict = self.renovator_attr_remove_func_dict[module_name] or {}
	
	local callback_list = func_dict[attr_key] or {}
	if table.getn(callback_list) == 0 then
		return
	end
	
	for _,callback_data in pairs(callback_list) do
		local callback_func = callback_data[1]
		local object = callback_data[2]
		callback_func(object,attr_key)
	end
end