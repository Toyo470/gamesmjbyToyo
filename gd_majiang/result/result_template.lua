
mrequire("base.layout_base")
mrequire ("mymodules")
result_Template = class("result_Template", base.layout_base.LayoutBase)

function result_Template:_do_prepare_init(other_index)
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.result_regain_image = ui_manager:register_widget_object("result_regain_image",other_index)
	self.result_time = ui_manager:register_widget_object("result_time",other_index)
	self.result_panel = ui_manager:register_widget_object("result_panel",other_index)
	self.result_title_image = ui_manager:register_widget_object("result_title_image",other_index)
	self.result_score3 = ui_manager:register_widget_object("result_score3",other_index)
	self.result_niaotxt = ui_manager:register_widget_object("result_niaotxt",other_index)
	self.result_txt3 = ui_manager:register_widget_object("result_txt3",other_index)
	self.result_hu = ui_manager:register_widget_object("result_hu",other_index)
	self.result_card_image = ui_manager:register_widget_object("result_card_image",other_index)
	self.result_zuan = ui_manager:register_widget_object("result_zuan",other_index)
	self.result_title = ui_manager:register_widget_object("result_title",other_index)
	self.result_room_Image_2 = ui_manager:register_widget_object("result_room_Image_2",other_index)
	self.result_txt0 = ui_manager:register_widget_object("result_txt0",other_index)
	self.result_score0 = ui_manager:register_widget_object("result_score0",other_index)
	self.result_score1 = ui_manager:register_widget_object("result_score1",other_index)
	self.result_room_btn_quit_room = ui_manager:register_widget_object("result_room_btn_quit_room",other_index)
	self.result_card = ui_manager:register_widget_object("result_card",other_index)
	self.result_config = ui_manager:register_widget_object("result_config",other_index)
	self.result_name0 = ui_manager:register_widget_object("result_name0",other_index)
	self.result_txt1 = ui_manager:register_widget_object("result_txt1",other_index)
	self.result_name3 = ui_manager:register_widget_object("result_name3",other_index)
	self.result_regain_btn = ui_manager:register_widget_object("result_regain_btn",other_index)
	self.result_cardbase = ui_manager:register_widget_object("result_cardbase",other_index)
	self.result_name1 = ui_manager:register_widget_object("result_name1",other_index)
	self.result_score2 = ui_manager:register_widget_object("result_score2",other_index)
	self.result_bg = ui_manager:register_widget_object("result_bg",other_index)
	self.result_name2 = ui_manager:register_widget_object("result_name2",other_index)
	self.result_roomnum = ui_manager:register_widget_object("result_roomnum",other_index)
	self.result_backcard = ui_manager:register_widget_object("result_backcard",other_index)
	self.result_over_btn = ui_manager:register_widget_object("result_over_btn",other_index)
	self.result_txt2 = ui_manager:register_widget_object("result_txt2",other_index)
	self.result_over_image = ui_manager:register_widget_object("result_over_image",other_index)
	self.result_base = ui_manager:register_widget_object("result_base",other_index)

	self.result_room_btn_quit_room:onClick(handler(self, self.click_result_room_btn_quit_room_event))
	self.result_regain_btn:onClick(handler(self, self.click_result_regain_btn_event))
	self.result_over_btn:onClick(handler(self, self.click_result_over_btn_event))

end

function result_Template:click_result_room_btn_quit_room_event()
end

function result_Template:click_result_regain_btn_event()
end

function result_Template:click_result_over_btn_event()
end



