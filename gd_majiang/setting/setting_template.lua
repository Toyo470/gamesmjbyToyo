
mrequire("base.layout_base")
mrequire("mymodules")
setting_Template = class("setting_Template", base.layout_base.LayoutBase)

function setting_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.setting_sound_slide = ui_manager:register_widget_object("setting_sound_slide",other_index)
	self.setting_Text_3 = ui_manager:register_widget_object("setting_Text_3",other_index)
	self.setting_music_bt = ui_manager:register_widget_object("setting_music_bt",other_index)
	self.setting_close_bt = ui_manager:register_widget_object("setting_close_bt",other_index)
	self.setting_Image_6 = ui_manager:register_widget_object("setting_Image_6",other_index)
	self.setting_Image_4 = ui_manager:register_widget_object("setting_Image_4",other_index)
	self.setting_sound_bt = ui_manager:register_widget_object("setting_sound_bt",other_index)
	self.setting_Image_1 = ui_manager:register_widget_object("setting_Image_1",other_index)
	self.setting_Image_5 = ui_manager:register_widget_object("setting_Image_5",other_index)
	self.setting_Text_2 = ui_manager:register_widget_object("setting_Text_2",other_index)
	self.setting_Text_1 = ui_manager:register_widget_object("setting_Text_1",other_index)
	self.setting_Image_3 = ui_manager:register_widget_object("setting_Image_3",other_index)
	self.setting_music_slide = ui_manager:register_widget_object("setting_music_slide",other_index)
	self.setting_Image_2 = ui_manager:register_widget_object("setting_Image_2",other_index)
	self.setting_floor = ui_manager:register_widget_object("setting_floor",other_index)
	self.setting_logout_bt = ui_manager:register_widget_object("setting_logout_bt",other_index)
	self.setting_Image_8 = ui_manager:register_widget_object("setting_Image_8",other_index)

	self.setting_music_bt:onClick(handler(self, self.click_setting_music_bt_event))
	self.setting_close_bt:onClick(handler(self, self.click_setting_close_bt_event))
	self.setting_sound_bt:onClick(handler(self, self.click_setting_sound_bt_event))
	self.setting_logout_bt:onClick(handler(self, self.click_setting_logout_bt_event))

end

function setting_Template:click_setting_music_bt_event()
end

function setting_Template:click_setting_close_bt_event()
end

function setting_Template:click_setting_sound_bt_event()
end

function setting_Template:click_setting_logout_bt_event()
end



