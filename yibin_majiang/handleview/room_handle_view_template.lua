
mrequire("base.layout_base")
mrequire("mymodules")
room_handle_view_Template = class("room_handle_view_Template", base.layout_base.LayoutBase)

function room_handle_view_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_handle_view_box = ui_manager:register_widget_object("room_handle_view_box",other_index)
	self.room_handle_view_guo = ui_manager:register_widget_object("room_handle_view_guo",other_index)

	self.room_handle_view_guo:onClick(handler(self, self.click_room_handle_view_guo_event))

end

function room_handle_view_Template:click_room_handle_view_guo_event()
end



