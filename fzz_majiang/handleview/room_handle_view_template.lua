
mrequire("base.layout_base")
mrequire("mymodules")
room_handle_view_Template = class("room_handle_view_Template", base.layout_base.LayoutBase)

function room_handle_view_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_handle_view_gang = ui_manager:register_widget_object("room_handle_view_gang",other_index)
	self.room_handle_view_guo = ui_manager:register_widget_object("room_handle_view_guo",other_index)
	self.room_handle_view_hu = ui_manager:register_widget_object("room_handle_view_hu",other_index)
	self.room_handle_view_peng = ui_manager:register_widget_object("room_handle_view_peng",other_index)
	self.room_handle_view_change = ui_manager:register_widget_object("room_handle_view_change",other_index)

	self.room_handle_view_gang:onClick(handler(self, self.click_room_handle_view_gang_event))
	self.room_handle_view_guo:onClick(handler(self, self.click_room_handle_view_guo_event))
	self.room_handle_view_hu:onClick(handler(self, self.click_room_handle_view_hu_event))
	self.room_handle_view_peng:onClick(handler(self, self.click_room_handle_view_peng_event))
	self.room_handle_view_change:onClick(handler(self, self.click_room_handle_view_change_event))

end

function room_handle_view_Template:click_room_handle_view_gang_event()
end

function room_handle_view_Template:click_room_handle_view_guo_event()
end

function room_handle_view_Template:click_room_handle_view_hu_event()
end

function room_handle_view_Template:click_room_handle_view_peng_event()
end

function room_handle_view_Template:click_room_handle_view_change_event()
end


