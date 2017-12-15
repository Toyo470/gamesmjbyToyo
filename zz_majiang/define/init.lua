manager = nil

function get_name_by_index(index)
	if manager == nil then
		return nil
	end
	local name = manager:get_name_by_index(index)
    return name
end

function get_index_by_name(name)
	if manager == nil then
		return nil
	end
	local index = manager:get_index_by_name(name)
    return index
end