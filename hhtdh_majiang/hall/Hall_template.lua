
mrequire("base.layout_base")
mrequire ("mymodules")
Hall_Template = class("Hall_Template", base.layout_base.LayoutBase)

function Hall_Template:_do_prepare_init(other_index)
	print("Hall_Template:_do_prepare_init(other_index)+++++++++++++====")
	other_index = other_index or ""
	local ui_manager = mymodules.manager:get_control_manager("ui")
	self.Hall_Sprite_14 = ui_manager:register_widget_object("Hall_Sprite_14",other_index)
	self.Hall_btn_diamond = ui_manager:register_widget_object("Hall_btn_diamond",other_index)
	self.Hall_txt_score = ui_manager:register_widget_object("Hall_txt_score",other_index)
	self.Hall_Sprite_13 = ui_manager:register_widget_object("Hall_Sprite_13",other_index)
	self.Hall_qian_21 = ui_manager:register_widget_object("Hall_qian_21",other_index)
	self.Hall_txt_score1 = ui_manager:register_widget_object("Hall_txt_score1",other_index)
	self.Hall_txt_nick = ui_manager:register_widget_object("Hall_txt_nick",other_index)
	self.Hall_tou_15 = ui_manager:register_widget_object("Hall_tou_15",other_index)
	self.Hall_img_sex = ui_manager:register_widget_object("Hall_img_sex",other_index)
	self.Hall_Particle_1 = ui_manager:register_widget_object("Hall_Particle_1",other_index)
	self.Hall_jia_31 = ui_manager:register_widget_object("Hall_jia_31",other_index)
	self.Hall_tou_2_16 = ui_manager:register_widget_object("Hall_tou_2_16",other_index)
	self.Hall_exit_51 = ui_manager:register_widget_object("Hall_exit_51",other_index)
	self.Hall_btn_exit = ui_manager:register_widget_object("Hall_btn_exit",other_index)
	self.Hall_btn_score = ui_manager:register_widget_object("Hall_btn_score",other_index)
	self.Hall_sv_game_list = ui_manager:register_widget_object("Hall_sv_game_list",other_index)
	self.Hall_sp_head = ui_manager:register_widget_object("Hall_sp_head",other_index)
	self.Hall_qian_2 = ui_manager:register_widget_object("Hall_qian_2",other_index)
	self.Hall_player_1_5 = ui_manager:register_widget_object("Hall_player_1_5",other_index)
	self.Hall_jia_3 = ui_manager:register_widget_object("Hall_jia_3",other_index)
	self.Hall_toux_11_5 = ui_manager:register_widget_object("Hall_toux_11_5",other_index)
	self.Hall_hall_bg_1 = ui_manager:register_widget_object("Hall_hall_bg_1",other_index)

	self.Hall_btn_exit:onClick(handler(self, self.click_Hall_btn_exit_event))

end

function Hall_Template:click_Hall_btn_exit_event()
end



