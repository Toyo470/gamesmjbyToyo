-- module(..., package.seeall)
mrequire("common")

MacrosManager = class("MacrosManager")

function MacrosManager:ctor()
	self.name_value_dict = {}
end

function MacrosManager:initialize()
	--print("MacrosManager:initialize-------------1--")
	cc.FileUtils:getInstance():addSearchPath("config/")
	local file_list = common.get_file_list_from_config("macros")
	--print("MacrosManager:initialize------------2---")
	local config_file = ""
	local root_table = {}
	local macros_value = ""
	local macros_name = ""
	
	for _,file_name in pairs(file_list) do
		config_file = "config/macros/" .. file_name
		--local str = cc.FileUtils:getInstance():getStringFromFile(config_file)
		local FileUtils = require("gd_majiang.fileutils")
		local str = FileUtils:getStringFromFile(config_file)

		root_table = json.decode(str)
		local macros_table = root_table["marcos_define"]
		
		for _,macros_element in pairs(macros_table) do
			macros_name = jsonparser.get_child_element_text(macros_element, names.MARCOS_NAME)
			macros_value = jsonparser.get_child_element_text(macros_element, names.MARCOS_VALUE)
			--print("----macros_name----macros_value--",macros_name,"-----------",macros_value,"-------------------------------------------")
			self.name_value_dict[macros_name] = macros_value
		end
	end
end

function MacrosManager:get_macros_number_value(macros_name)
	local value = self.name_value_dict[macros_name]
	if value == nil then
		return 0.0
	else
		return tonumber(value)
	end
end

function MacrosManager:get_macros_str_value(macros_name)
	local value = self.name_value_dict[macros_name]
	if value == nil then
		return ""
	else
		return tostring(value)
	end
end

function MacrosManager:get_macors_content(macros_name, param)
	local content = self.name_value_dict[macros_name]
	if content == nil then
		return ""
	end
	
	if param == nil then
		return content
	else
		return string.format(content,param)
	end
end