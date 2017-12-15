
mrequire("base.layout_base")
mrequire("mymodules")
roomhandle_Template = class("roomhandle_Template", base.layout_base.LayoutBase)

function roomhandle_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.roomhandle_room_btn_invite = ui_manager:register_widget_object("roomhandle_room_btn_invite",other_index)
	self.roomhandle_room_Image_2 = ui_manager:register_widget_object("roomhandle_room_Image_2",other_index)
	self.roomhandle_Text_1 = ui_manager:register_widget_object("roomhandle_Text_1",other_index)
	self.roomhandle_room_btn_quit_room = ui_manager:register_widget_object("roomhandle_room_btn_quit_room",other_index)

	self.roomhandle_room_btn_invite:onClick(handler(self, self.click_roomhandle_room_btn_invite_event))
	self.roomhandle_room_btn_quit_room:onClick(handler(self, self.click_roomhandle_room_btn_quit_room_event))

end

function roomhandle_Template:click_roomhandle_room_btn_invite_event()
end

function roomhandle_Template:click_roomhandle_room_btn_quit_room_event()
end



