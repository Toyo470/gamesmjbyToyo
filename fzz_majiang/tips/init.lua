mrequire("macros")

function show_tips( title_index,content_index,sure_callback,cancel_callback)
	-- body
	local title = macros.get_macros_str_value(title_index)
	local content = macros.get_macros_str_value(content_index)

	local layout_object = layout.reback_layout_object("tips")
	layout_object:reset_confirm_content(title,content)

	layout_object:reset_confirm_sure_callback(sure_callback)
	layout_object:reset_confirm_cancel_callback(cancel_callback)
end


function show_tips_only_sure( title_index,content_index,arg_index,sure_callback)
	-- body
	local title = macros.get_macros_str_value(title_index)

	local content = macros.get_macros_str_value(content_index)
	content = string.format(content,arg_index)
	local layout_object = layout.reback_layout_object("tips")
	layout_object:reset_confirm_content(title,content)
	layout_object:reset_confirm_sure_callback(sure_callback)
	layout_object:set_only_sure()
end

function show_tips_dissove( title,content,sure_callback,cancel_callback,show_update_flag)
	title = title or "title"
	content = content or "content"
	local layout_object = layout.reback_layout_object("tips_dissove")
	layout_object:reset_confirm_content(title,content)

	layout_object:reset_confirm_sure_callback(sure_callback)
	layout_object:reset_confirm_cancel_callback(cancel_callback)
	layout_object:set_show_update_flag(show_update_flag)


	local room_card_result = layout.manager:get_layout_object("room_card")
	if room_card_result ~= nil then
		local z_resultZOrder = room_card_result:getLocalZOrder()
	    layout_object:setLocalZOrder(z_resultZOrder+1)
	end

	local result_object = layout.manager:get_layout_object("result")
	if result_object ~= nil then
		local z_resultZOrder = result_object:getLocalZOrder()
	    layout_object:setLocalZOrder(z_resultZOrder+1)
	end
end


function show_tips_212( title,content,sure_callback)
	-- body
	local layout_object = layout.reback_layout_object("tips")
	layout_object:reset_confirm_content(title,content)
	layout_object:reset_confirm_sure_callback(sure_callback)
	layout_object:set_only_sure()
	layout_object:setLocalZOrder(10)

	local room_card_result = layout.manager:get_layout_object("room_card")
	if room_card_result ~= nil then
		local z_resultZOrder = room_card_result:getLocalZOrder()
	    layout_object:setLocalZOrder(z_resultZOrder+3)
	end

	local result_object = layout.manager:get_layout_object("result")
	if result_object ~= nil then
		local z_resultZOrder = result_object:getLocalZOrder()
	    layout_object:setLocalZOrder(z_resultZOrder+1)
	end

end