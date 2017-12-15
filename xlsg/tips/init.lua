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

end


function show_tips_212( title,content,sure_callback)
	-- body
	local layout_object = layout.reback_layout_object("tips")
	layout_object:reset_confirm_content(title,content)
	layout_object:reset_confirm_sure_callback(sure_callback)
	layout_object:set_only_sure()

end