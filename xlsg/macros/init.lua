manager = nil

function get_macros_str_value(macros_name)
	if manager == nil then
		return ""
	end
	
	return manager:get_macros_str_value(macros_name)
end

function get_macros_number_value(macros_name)
	if manager == nil then
		return ""
	end
	
	return manager:get_macros_number_value(macros_name)
end

function get_macors_content(macros_name, param)
	if manager == nil then
		return ""
	end
	
	return manager:get_macors_content(macros_name, param)
end