
function deal_click( widget_name )
	-- body
	local ui_manager = ui.manager
	if ui_manager ~= nil then
		local widget_object = ui_manager:get_widget_object( widget_name )

		if widget_object and widget_object.onClick
	end
end