
mrequire("base.layout_base")
mrequire("mymodules")
room_base_Template = class("room_base_Template", base.layout_base.LayoutBase)

function room_base_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_base_rdimage = ui_manager:register_widget_object("room_base_rdimage",other_index)
	self.room_base_rd = ui_manager:register_widget_object("room_base_rd",other_index)
	self.room_base_text_btntxt = ui_manager:register_widget_object("room_base_text_btntxt",other_index)
	self.room_base_text_btn = ui_manager:register_widget_object("room_base_text_btn",other_index)
	self.room_base_sumpeo = ui_manager:register_widget_object("room_base_sumpeo",other_index)
	self.room_base_num = ui_manager:register_widget_object("room_base_num",other_index)
	self.room_base_exit = ui_manager:register_widget_object("room_base_exit",other_index)
	self.room_base_top = ui_manager:register_widget_object("room_base_top",other_index)
	self.room_base_room_bg = ui_manager:register_widget_object("room_base_room_bg",other_index)
	self.room_base_btn = ui_manager:register_widget_object("room_base_btn",other_index)
	self.room_base_video = ui_manager:register_widget_object("room_base_video",other_index)
	self.room_base_txt = ui_manager:register_widget_object("room_base_txt",other_index)
	self.room_base_gouptime = ui_manager:register_widget_object("room_base_gouptime",other_index)
	self.room_base_talk = ui_manager:register_widget_object("room_base_talk",other_index)

	self.room_base_rd:onClick(handler(self, self.click_room_base_rd_event))
	self.room_base_text_btn:onClick(handler(self, self.click_room_base_text_btn_event))
	self.room_base_exit:onClick(handler(self, self.click_room_base_exit_event))
	self.room_base_btn:onClick(handler(self, self.click_room_base_btn_event))
	self.room_base_video:onClick(handler(self, self.click_room_base_video_event))
	self.room_base_talk:onClick(handler(self, self.click_room_base_talk_event))

end

function room_base_Template:click_room_base_rd_event()
end

function room_base_Template:click_room_base_text_btn_event()
end

function room_base_Template:click_room_base_exit_event()
end

function room_base_Template:click_room_base_btn_event()
end

function room_base_Template:click_room_base_video_event()
end

function room_base_Template:click_room_base_talk_event()
end



