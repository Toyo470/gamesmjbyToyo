
function get_child_element_text(parent,key_name)
	local element = parent[key_name]
	if element ~= nil then
		return tostring(element)
	else
		return ""
	end
end

function get_child_element_number(parent,key_name)
	local element = parent[key_name]
	if element ~= nil then
		return tonumber(element)
	else
		return 0
	end
end

function get_child_element_table(parent,key_name)
	local element = parent[key_name]
	if element ~= nil then
		return element
	else
		return {}
	end
end