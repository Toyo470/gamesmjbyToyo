mrequire("mymodules")
manager = nil


function reback_layout_object(layout_name,other_index,parent_widget,is_need_game_bg,is_hide_clear,item_layout_flag)
	layout_name = layout_name or ""
	other_index = other_index or ""
	parent_widget = parent_widget or nil
	if is_need_game_bg == nil then is_need_game_bg = true end
	if is_hide_clear == nil then is_hide_clear = true end

	local layout_manager = mymodules.manager:get_control_manager("layout")
	if layout_manager == nil then
		return nil 
	end
	print("layout_name .. other_index--------------",layout_name .. other_index)
	local layout_object = layout_manager:get_layout_object(layout_name .. tostring(other_index))
	if layout_object == nil then
		layout_object = layout_manager:create_layout_object(layout_name, tostring(other_index),parent_widget,is_need_game_bg,is_hide_clear,item_layout_flag)
	end
	return layout_object
end

function hide_layout(layout_name)
	local layout_manager = mymodules.manager:get_control_manager("layout")
	if layout_manager == nil then
		return nil 
	end
	layout_manager:hide_layout(layout_name)
end


function dump_layout_name()
	local layout_manager = mymodules.manager:get_control_manager("layout")
	if layout_manager == nil then
		return nil 
	end
	layout_manager:dump_layout_name()
end
