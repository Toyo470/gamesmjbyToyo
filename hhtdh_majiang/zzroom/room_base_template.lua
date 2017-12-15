
mrequire("base.layout_base")
mrequire("mymodules")
room_base_Template = class("room_base_Template", base.layout_base.LayoutBase)

function room_base_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.room_base_txt1 = ui_manager:register_widget_object("room_base_txt1",other_index)
	self.room_base_room_bg = ui_manager:register_widget_object("room_base_room_bg",other_index)
	self.room_base_num = ui_manager:register_widget_object("room_base_num",other_index)
	self.room_base_talk = ui_manager:register_widget_object("room_base_talk",other_index)
	self.room_base_video = ui_manager:register_widget_object("room_base_video",other_index)
	self.room_base_gamemsg = ui_manager:register_widget_object("room_base_gamemsg",other_index)
	self.room_base_tab = ui_manager:register_widget_object("room_base_tab",other_index)
	self.room_base_btn = ui_manager:register_widget_object("room_base_btn",other_index)
	self.room_base_timebase = ui_manager:register_widget_object("room_base_timebase",other_index)
	self.room_base_btn_exit = ui_manager:register_widget_object("room_base_btn_exit",other_index)
	self.room_base_timertxt = ui_manager:register_widget_object("room_base_timertxt",other_index)
	self.room_base_xi = ui_manager:register_widget_object("room_base_xi",other_index)
	self.room_base_txt2 = ui_manager:register_widget_object("room_base_txt2",other_index)
	self.room_base_bei = ui_manager:register_widget_object("room_base_bei",other_index)
	self.room_base_nan = ui_manager:register_widget_object("room_base_nan",other_index)
	self.room_base_txt = ui_manager:register_widget_object("room_base_txt",other_index)
	self.room_base_dong = ui_manager:register_widget_object("room_base_dong",other_index)
	self.room_base_gouptime = ui_manager:register_widget_object("room_base_gouptime",other_index)
	self.room_base_lessnum = ui_manager:register_widget_object("room_base_lessnum",other_index)

	self.room_base_talk:onClick(handler(self, self.click_room_base_talk_event))
	self.room_base_video:onClick(handler(self, self.click_room_base_video_event))
	self.room_base_btn_exit:onClick(handler(self, self.click_room_base_btn_exit_event))
	self.room_base_btn:onClick(handler(self, self.click_room_base_btn_event))

end

function room_base_Template:click_room_base_talk_event()
end

function room_base_Template:click_room_base_video_event()
end

function room_base_Template:click_room_base_btn_exit_event()
end

function room_base_Template:click_room_base_btn_event()
end



